## 使用 web audio API 创建一个简单的音频可视化效果

网页音频接口最有趣的特性之一它就是可以获取频率、波形和其它来自声源的数据，这些数据可以被用作音频可视化。


### 关键词

* 音频上下文
* 音频节点
* 输出到canvas

### 音频上下文 （AudioContent）

音频中的 `AudioContext` 可以类比于 `canvas` 中的 `context`，其中包含了一系列用来处理音频的 `API`，简而言之，就是可以用来控制音频的各种行为，比如播放、暂停、音量大小等等等等。

``` 
    const audioContext = new AudioContext();
```

一般我们在网页上播放音频，都是像

```
    <audio autoplay src="music.mp3"></audio>
```

或是

```
    const audio = new Audio();
    audio.autoplay = true;
    audio.src = 'music.mp3';
```

这两种方式播放音频的代码非常简单，但是这些方式有他的局限性，只能控制播放、暂停等基本的播放控制。如果我们想要更“高级”地操作音频，比如音频可视化、声道分割甚至混响、调音等等，就需要`AudioContext`来实现。

```
    const init = async () => {
        const audioContext = new AudioContext();
        const requestConfig = {
            responseType: 'arraybuffer'
        };
        let audioData = await axios.get(audioPath, requestConfig);
        const source = audioContext.createBufferSource();
        source.buffer = await audioContext.decodeAudioData(audioData.data);
        source.connect(audioContext.destination);
        source.start();
    };
    init();
```

以上就是AudioContext播放音频最简单的🌰,其实就只做了三件事情，获取音频资源、解析成音频buffer格式以及播放音频。

### 音频节点（AudioNode）

上面的🌰里面讲了如何创建`AudioContext`来播放，但真正重要的功能还没有实现，音频节点正是来实现这些个功能

那么什么是音频节点呢？可以把它理解为是通过「管道」 `connect` 连接在「容器」`source` 和「出口」 `destination` 之间一系列的音频「处理器」。`AudioContext` 提供了许多「处理器」用来处理音频，比如音量「处理器」 `GainNode`、延时「处理器」 `DelayNode` 或声道合并「处理器」 `ChannelMergerNode` 等等。

前面所提到的「管道」 `connect` 也是由音频节点 `AudioNode` 提供的，所以你猜的没错，「容器」 `source` 也是一种音频节点。

#### GainNode

这是操作音频音量的节点

```
    const init = async () => {
        const audioContext = new AudioContext();
        const requestConfig = {
            responseType: 'arraybuffer'
        };
        let audioData = await axios.get(audioPath, requestConfig);
        const source = audioContext.createBufferSource();

        const gainNode = audioContext.createGain(); 

        source.buffer = await audioContext.decodeAudioData(audioData.data);

        source.connect(gainNode);
        gainNode.connect(audioContext.destination);

        source.start();
    };
    init();
```

可以发现和上面提到的 `playAudio` 方法很像，区别只是 `source` 不直接 connect 到 `source.destination`，而是先 connect 到 `gainNode`，然后再通过 `gainNode` connect 到 `source.destination`。这样其实就把「音量处理器」装载上去了，此时我们通过更新 `gainNode.gain.value` 的值（`0 - 1` 之间）就可以控制音量的大小了。


#### AnalyserNode

AnalyserNode能够提供实时频率及时间域分析的节点。它只输入输出音频，不对音频做任何操作。

```
    const init = async () => {
        const audioContext = new AudioContext();
        const requestConfig = {
            responseType: 'arraybuffer'
        };
        let audioData = await axios.get(audioPath, requestConfig);
        const source = audioContext.createBufferSource();
        // 创建分析节点
        const analyser = audioContext.createAnalyser();
        // 设置分析节点的采样频率
        analyser.fftSize = 32;
        const gainNode = audioContext.createGain(); 
        source.buffer = await audioContext.decodeAudioData(audioData.data);
        // 加入分析节点
        source.connect(analyser);
        analyser.connect(gainNode);
        gainNode.connect(audioContext.destination);

        source.start();
    };
    init();
```

通过AnalyserNode实时分析音频,`Analyser Node` 将在一个特定的频率域里使用快速傅立叶变换(Fast Fourier Transform (FFT) )来捕获音频数据，这取决于你给 AnalyserNode.fftSize 属性赋的值（如果没有赋值，默认值为2048）。

```
    const init = async () => {
        const audioContext = new AudioContext();
        const requestConfig = {
            responseType: 'arraybuffer'
        };
        let audioData = await axios.get(audioPath, requestConfig);
        const source = audioContext.createBufferSource();
        const analyser = audioContext.createAnalyser();
        analyser.fftSize = 32;
        const gainNode = audioContext.createGain(); 
        source.buffer = await audioContext.decodeAudioData(audioData.data);
        source.connect(analyser);
        analyser.connect(gainNode);
        gainNode.connect(audioContext.destination);
        // 获取单个声道的FFT长度
        let bufferLength = analyser.frequencyBinCount;
        // 将FFT长度作为数组的长度，也就从FFT中采集多少数据点。
        let dataArray = new Uint8Array(bufferLength);
        source.start();
    };
    init();
```

上面的栗子已经从音频中采样到了音频数据，现在可以把数据展示到canvas上。但是在canvas绘制过程中需要获得当前正在播放的数据，`AnalyserNode.getByteFrequencyData()`就可以做到。

### 输出到canvas

```
    step = async() => {
        requestAnimationFrame(this.step);

        this.ctx.clearRect(0, 0, this.WIDTH, this.HEIGHT);
        const audio = await this.audio;
        audio.ctx.getByteFrequencyData(audio.data);

        this.frequency.draw(audio.data);
    }
```

```
    draw(data: number[]) {
        this.canvas_ctx.fillStyle = '#000000';
        this.canvas_ctx.fillRect(this.area[0], this.area[1], this.area[2], this.area[3]);
        for (let i = 0; i < this.squareCount; i ++) {
            this.canvas_ctx.beginPath();
            let barHeight: number = data[i] / 512 * this.areaHeight;
            this.canvas_ctx.fillStyle = this.gard;
            this.canvas_ctx.fillRect(this.area[0] + (this.squareWidth + this.squareSpace) * i, this.area[3] * 0.7 - barHeight, this.squareWidth, barHeight);
            this.canvas_ctx.closePath();
        }
        this.canvas_ctx.closePath();
    }
```


### 更多阅读

Web Audio API (https://webaudio.github.io/web-audio-api/#audioapi)

Visualizations with Web Audio API (https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Visualizations_with_Web_Audio_API)

Web Audio API 介绍和 web 音频应用案例分析 (https://juejin.im/entry/5a13ebd26fb9a0451e3f6c47)

web audio api 前端音效处理 (https://zenaro.github.io/blog/2017/03/01/web-audio-api/)
