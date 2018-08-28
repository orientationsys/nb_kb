# 原生懒加载技术

最近，谷歌浏览器 Chrome的一个新功能 LazyLoad 被设计出来由浏览器支持进行对Iframe和图片进行懒加载，极大的提升网站的加载速度和用户体验。

## 这个技术是如何工作的呢？

和目前我们通过hack手段进行的懒加载类似，是延迟加载不重要的内容来极大的提升整体网站的感知性能。

由于是最新的提案功能，如果这个功能提案成功，将可以自动的设置页面中不同区块内容的加载：

- 图片和Iframe将会被分析是否是重要的
- 如果这些内容是无意义的则会被： 
 - 延迟加载内容直到用户滚动到内容附近
 - 图片用 Range request 来获取部分内容（图片的长宽大小等）来预先的生成空白的图片

### [一个新的提案](https://docs.google.com/document/d/1e8ZbVyUwgIkQMvJma3kKUDg8UUkLRRdANStqKuOIvHg/edit) 有一些非常有趣的内容：

- LazyLoad 是由2个不同的机制组成：LazyImages 和 LazyFrames
- 当用户滚到到被设置的触发加载的距离（Pixels）被延迟加载的图片和Iframes将会被加载，而设置被加载的距离和以下三个因素有关：
	- 是否是图片或者Iframe
	- Data Saver 是开的还是关的
	- 和 [effective connection type](https://googlechrome.github.io/samples/network-information/)
- 一旦浏览器开始加载网页，如果图片是在网页下端的部分，那么它将会被 [range request](https://googlechrome.github.io/samples/network-information/) 去获取部分图片资料来建立图片的大小和规模，这个建立起来的图片（不是真正的图片，相当于预加载时显示的伪图片）将会先在网页上显示。

这个 [lazyload attribute](https://whatpr.org/html/3752/urls-and-fetching.html#lazy-loading-attributes) 将会允许你自定义设置哪一个元素需要进行懒加载

例如：

`<iframe src="ads.html" lazyload="on"></iframe>`

这里有三个选项：

- on  - 表示直接阻止加载直到这个内容成功加载并能查看
- off - 关闭懒加载，不管内容是否可见，直接加载
- auto - 让浏览器自己决定是否加载内容,这样和是否使用懒加载无任何区别

## 兼容性

因为是个实验功能，目前该功能只能由chrome 每日编译版来进行使用。

## 如何使用

打开 [Chrome Canary](https://www.google.com/chrome/canary/)  在地址栏输入 `chrome://flags/#enable-lazy-image-loading` 然后点击enable 则可以开始使用