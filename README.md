# CSS （层叠样式表）

层叠样式表(英文全称：Cascading Style Sheets)是一种用来表现HTML（标准通用标记语言的一个应用）或XML（标准通用标记语言的一个子集）等文件样式的计算机语言。CSS不仅可以静态地修饰网页，还可以配合各种脚本语言动态地对网页各元素进行格式化。

CSS 能够对网页中元素位置的排版进行像素级精确控制，支持几乎所有的字体字号样式，拥有对网页对象和模型样式编辑的能力。

## 定位

定位的概念就是它允许你定义一个元素相对于其他正常元素的位置，它应该出现在哪里，这里的其他元素可以是父元素，另一个元素甚至是浏览器窗口本身。

谈及定位，我们就得从position属性说起：static、relative、absolute、fixed、sticky和inherit。

static(默认)：元素框正常生成。块级元素生成一个矩形框，作为文档流的一部分；行内元素则会创建一个或多个行框，置于其父元素中。

relative：元素框相对于之前正常文档流中的位置发生偏移，并且原先的位置仍然被占据。发生偏移的时候，可能会覆盖其他元素。

absolute：元素框不再占有文档流位置，并且相对于包含块进行偏移(所谓的包含块就是最近一级外层元素position不为static的元素)

fixed：元素框不再占有文档流位置，并且相对于视窗进行定位

sticky：(这是css3新增的属性值)粘性定位，其实，它就相当于relative和fixed混合。最初会被当作是relative，相对于原来的位置进行偏移；一旦超过一定阈值之后，会被当成fixed定位，相对于视口进行定位。

## 盒子模型

![](https://mmbiz.qpic.cn/mmbiz_jpg/zPh0erYjkib3Lx1WeVMsSMiabsvKteCWGXsYZZt33pr4hGJmmTpTYictRYOpNWvoDXrcnBJPkyHtscMdAKbDAnupQ/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1)

这是标准盒子模型，可以看到width的长度等于content的宽度；而当将box-sizing的属性值设置成border-box时，盒子模型的width=border+padding+content的总和。

## 尺寸

除了px，我们可以来介绍一下下面几个单位：

百分比：百分比的参照物是父元素，50%相当于父元素width的50%

rem：这个对于复杂的设计图相当有用，它是html的font-size的大小

em：它虽然也是一个相对的单位，相对于父元素的font-size，但是，并不常用，主要是计算太麻烦了。

## 两栏布局

![](https://mmbiz.qpic.cn/mmbiz_jpg/zPh0erYjkib3Lx1WeVMsSMiabsvKteCWGXic0jUQusvpJqr2g8uTRpIKHSnuc5oXJvU05icxuib1URlKQ6vpvzRUzdA/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1)

```
<body>

  <div class="left">定宽</div>

  <div class="right">自适应</div>

</body>



.left{

  width: 200px;

  height: 600px;

  background: red;

  float: left;

  display: table;


}

 

.right{

  margin-left: 210px;

  height: 600px;

  background: yellow;

}
```
## 三栏布局

![](https://mmbiz.qpic.cn/mmbiz_png/zPh0erYjkib3Lx1WeVMsSMiabsvKteCWGXuUbrI4g0Ia0f5FBTbEYkBwmBWWST2icX2Tk6xx0icx3QryMmT4mSq89A/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1)

```
<div class="left">左栏</div>

<div class="middle">中间栏</div>

<div class="right">右栏</div>



.left{

    background: yellow;

    width: 200px;

    height: 300px;

    position: absolute;

    top: 0;

    left: 0;

}

.middle{

    height: 300px;

    margin: 0 220px;

    background: red;

}

.right{

    height: 300px;

    width: 200px;

    position: absolute;

    top: 0;

    right: 0;

    background: green;

}
```
