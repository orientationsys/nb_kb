## web audio API

网页音频接口最有趣的特性之一它就是可以获取频率、波形和其它来自声源的数据，这些数据可以被用作音频可视化。这篇文章将解释如何做到可视化，并提供了一些基础使用案例。


### 基本概念

要从你的音频源获取数据，你需要一个 AnalyserNode节点，它可以用 AudioContext.createAnalyser() 方法创建，比如：

```
    var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    var analyser = audioCtx.createAnalyser();
```

然后把这个节点（node）连接到你的声源：

```
    source = audioCtx.createMediaStreamSource(stream);
    source.connect(analyser);
    analyser.connect(distortion);
```

<p bgcolor ="#fff3d4">注意： 分析器节点(Analyser Node) 不一定输出到另一个节点，不输出时也可以正常使用。但前提是它必须与一个声源相连（直接或者通过其他节点间接相连都可以）。</p>

分析器节点(Analyser Node) 将在一个特定的频率域里使用快速傅立叶变换(Fast Fourier Transform (FFT) )来捕获音频数据，这取决于你给 AnalyserNode.fftSize 属性赋的值（如果没有赋值，默认值为2048）。

<p>注意： 你也可以为FFT数据缩放范围指定一个最小值和最大值，使用AnalyserNode.minDecibels 和AnalyserNode.maxDecibels进行设置，要获得不同数据的平均常量，使用 AnalyserNode.smoothingTimeConstant。阅读这些页面以获得更多如何使用它们的信息。</p>

要捕获数据，你需要使用 AnalyserNode.getFloatFrequencyData() 或 AnalyserNode.getByteFrequencyData() 方法来获取频率数据，用 AnalyserNode.getByteTimeDomainData() 或 AnalyserNode.getFloatTimeDomainData() 来获取波形数据。


