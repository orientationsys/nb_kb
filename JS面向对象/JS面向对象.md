# JS的面向对象

_js是不存在对象的!_

摘自You don't know js: 

> Where does JavaScript fall in this regard? JS has had some class-like syntactic elements (like new and instanceof) for quite awhile, and more recently in ES6, some additions, like the class keyword (see Appendix A).
But does that mean JavaScript actually has classes? Plain and simple: No.

_js拥有类似实现类的方法，但是与JAVA等语言的类(Class)有一定的差别_

传统语言的写法：

```
	class father {
		construct(id) {
			id = id;
		}
	}
	
	class child extends father {
		construct() {
			super(id);
		}
	}
```

js在es6之前是不可以这样写的，但是es6推出了 class 类语法糖，虽然可以这么写OO，但是实际上的代码和其他语言JAVA等是不一样的


_js中没有类但是又想实现面向对象类的形式则需要使用一些小技巧来实现_



## 基于原型链的面向对象写法(委托)

js的委托写法并不是和传统的面向对象会复制父类的方法等，而是关联。js有原型链，可以通过 new 关键词，Object.create()等方式来进行prototype的相互联系和指向。因此类似多太这类复写父类方法的模式是不存在的，如果方法名一样则会引起歧义。

以下是典型的原型继承写法：

```
function Foo(who) {
  this.me = who;
}
Foo.prototype.identify = function() {
  return 'I am ' + this.me;
};
function Bar(who) {
  Foo.call(this, who);
}
Bar.prototype = new Foo();
Bar.prototype.speak = function() {
  console.log('Hello, ' + this.identify() + '.');
};
var b1 = new Bar('b1');
var b2 = new Bar('b2');
b1.speak();
b2.speak();
```

以下是对象关联的写法：

```
Foo = {
	init: function(who) {
		this.me = who;
	},
	identify: function() {
		return `I am ${this.me}`;
	}
}

Bar = Object.create(Foo) // Bar.prototype 指向了 Foo.prototype

Bar.speak = function() {
	console.log(`Hello ${this.identify()}`);
}

const b1 = Object.create(Bar);
b1.init('b1'); // 会根据原型链寻找init方法
const b2 = Object.create(Bar);
b2.init('b2');
b1.speak();
b2.speak();
```

以上代码都关联了父类Foo，并且重新写了speak函数，写法与传统语言的OO差距非常大。





