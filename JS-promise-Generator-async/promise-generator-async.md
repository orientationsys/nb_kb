一、异步
1、所谓“异步”，简单说就是一个任务分成两段，先执行第一段，然后转而执行其他任务，等做好了准备，再回过头执行第二段。

2、异步编程方式：
（1）回调函数
（2）事件监听
（3）发布/订阅者
（4）Promise对象

3、所谓回调函数，就是把第二段单独写在一个函数里面，等到重新执行这个任务的时候，就直接调用这个函数。
    回调函数的异步方式容易形成多重嵌套，多个异步操作形成了强耦合，只要有一个操作需要修改，它的上层回调函数和下层回调函数，
    可能都要跟着修改。这种情况就称为”回调函数地狱”（callback hell）。Promise可以解决callback hell问题，Promise对
    象允许回调函数的嵌套，改成链式调用。

二、Promise
    Promise 是异步编程的一种解决方案,简单说就是一个容器，里面保存着某个未来才回结束的事件(通常是一个异步操作）的结果。从
    语法上说，Promise是一个对象，从它可以获取异步操作的消息。Promise 对象的状态不受外界影响.

    它有三种状态，padding（进行中），fulfilled（已经成功），rejected（已经失败）

    它的状态只能从pending变为fulfilled，或者从padding变为rejected，这两种状态只要发生就不会再变。

    ES6规定，Promise对象是一个构造函数，用来生成Promise实例

    const promist = new Promise(function(resolve,reject){
        if(/*异步操作成功*/){
            resolve(value);
        }else{
            reject(error);
        }
    })

    resolve函数的作用是，将Promise对象的状态从“未完成”变为“成功”（即从 pending 变为 resolved），在异步操作成功时调用，
    并将异步操作的结果，作为参数传递出去；

    reject函数的作用是，将Promise对象的状态从“未完成”变为“失败”（即从 pending 变为 rejected），在异步操作失败时调用，
    并将异步操作报出的错误，作为参数传递出去。

    Promise 实例生成以后，可以用then catch 方法分别指定resolved状态和rejected状态的回调函数。

        promise.then(function(success){
            success
        }).catch(function(err){
            err
        })

    Promise.all可以将多个Promise实例包装成一个新的Promise实例。同时，成功和失败的返回值是不同的，成功的时候返回的是一个结
    果数组，而失败的时候则返回最先被reject失败状态的值。

        let p1 = new Promise((resolve, reject) => { resolve('成功了') }) 
        let p2 = new Promise((resolve, reject) => { resolve('success') }) 
        let p3 = Promse.reject('失败') 
        Promise.all([p1, p2]).then((result) => { 
            console.log(result) //['成功了', 'success'] 
            }).catch((error) => { 
            console.log(error) 
            }) 
        Promise.all([p1,p3,p2]).then((result) => { 
            console.log(result) 
            }).catch((error) => {
            console.log(error) // 失败了，打出 '失败' 
            })

        
    Promse.race就是赛跑的意思，意思就是说，Promise.race([p1, p2, p3])里面哪个结果获得的快，就返回那个结果，不管结果本身
    是成功状态还是失败状态。

        let p1 = new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve('success')
        },1000)
        })

        let p2 = new Promise((resolve, reject) => {
        setTimeout(() => {
            reject('failed')
        }, 500)
        })

        Promise.race([p1, p2]).then((result) => {
        console.log(result)
        }).catch((error) => {
        console.log(error)  // 打开的是 'failed'
        })

二、Generator

    语法上，可以把理解成，Generator 函数是一个状态机，封装了多个内部状态。

    形式上，Generator 函数是一个普通函数。

    整个Generator函数就是一个封装的异步任务，或者说是异步任务的容器，异步操作需要暂停的地方，都用yield语句。

    Generator函数特征：

        （1）function 关键字和函数之间有一个星号(*),且内部使用yield表达式，定义不同的内部状态。

        （2）调用Generator函数后，该函数并不执行，返回的也不是函数运行结果，而是一个指向内部状态的指针对象。
        function* fn(){   // 定义一个Generator函数
            yield 'hello';
            yield 'world';
            return 'end';
        }
        var f1 =fn();           // 调用Generator函数
        console.log(f1);        // fn {[[GeneratorStatus]]: "suspended"}
        console.log(f1.next()); // {value: "hello", done: false}
        console.log(f1.next()); // {value: "world", done: false}
        console.log(f1.next()); // {value: "end", done: true}
        console.log(f1.next()); // {value: undefined, done: true}

    但是，调用Generator函数后，函数并不执行，返回的也不是函数执行后的结果，而是一个指向内部状态的指针对象。

    下一步，必须调用遍历器对象的next方法，使得指针移向下一个状态。即：每次调用next方法，内部指针就从函数头部或上一次停下来的地方
    开始执行，直到遇到下一个yield表达式（或return语句）为止。

    Generator 函数是分段执行的，yield表达式是暂停执行的标记，而next方法可以恢复执行。

    Generator函数的暂停执行的效果，意味着可以把异步操作写在yield语句里面，等到调用next方法时再往后执行。这实际上等同于不需要写
    回调函数了，因为异步操作的后续操作可以放在yield语句下面，反正要等到调用next方法时再执行。所以，Generator函数的一个重要实际
    意义就是用来处理异步操作，改写回调函数。

    Generator 函数返回的遍历器对象，只有调用next方法才会遍历下一个内部状态，所以其实提供了一种可以暂停执行的函数。

    yield表达式就是暂停标志。

    yield表达式后面的表达式，只有当调用next方法、内部指针指向该语句时才会执行。

    使用yield需注意：

        （1）yield语句只能用于function* 的作用域，如果function* 的内部还定义了其他的普通函数，则函数内部不允许使用yield语句。

        （2）yield语句如果参与运算，必须用括号括起来。

    return方法跟next方法的区别:

        1)return终结遍历，之后的yield语句都失效；next返回本次yield语句的返回值。

        2)return没有参数的时候，返回{ value: undefined, done: true }；next没有参数的时候返回本次yield语句的返回值。

        3)return有参数的时候，覆盖本次yield语句的返回值，也就是说，返回{ value: 参数, done: true }；next有参数的时候，覆盖上
        次yield语句的返回值，返回值可能跟参数有关（参数参与计算的话），也可能跟参数无关（参数不参与计算）。

    遍历器对象的next方法的运行逻辑：

        （1）遇到yield表达式，就暂停执行后面的操作，并将紧跟在yield后面的那个表达式的值，作为返回的对象的value属性值。

        （2）下一次调用next方法时，再继续往下执行，直到遇到下一个yield表达式。

        （3）如果没有再遇到新的yield表达式，就一直运行到函数结束，直到return语句为止，并将return语句后面的表达式的值，作为返回的对象
        的value属性值。

        （4）如果该函数没有return语句，则返回的对象的value属性值为undefined。
    
        function* foo(x) {
            var y = 2 * (yield (x + 1));
            var z = yield (y / 3);
            return (x + y + z);
        }

        var a = foo(5);
        console.log(a.next()); // Object{value:6, done:false} 

        第二次运行next方法的时候不带参数，导致y的值等于2 * undefined（即NaN），除以3以后还是NaN
        console.log(a.next()); // Object{value:NaN, done:false} 

        第三次运行Next方法的时候不带参数，所以z等于undefined，返回对象的value属性等于5 + NaN + undefined，即NaN。
        console.log(a.next()); // Object{value:NaN, done:true}

        var b = foo(5);
        console.log(b.next());   // {value:6, done:false } 
        第一次调用b的next方法时，返回x+1的值6

        console.log(b.next(12)); // {value:8, done:false } 
        第二次调用next方法，将上一次yield表达式的值设为12，因此y等于24，返回y / 3的值8；

        console.log(b.next(13)); // {value:42, done:true } 
        第三次调用next方法，将上一次yield表达式的值设为13，因此z等于13，这时x等于5，y等于24，所以return语句的值等于42。


三、async
    async 函数算是一个语法糖，使异步函数、回调函数在语法上看上去更像同步函数。

    async function asyncLoadData (urlOne, urlTwo) {
        let dataOne = await loadData (urlOne);
        let dataTwo = await loadData (urlTwo);
    }
    loadData方法是异步获取数据的方法.

    在 async 函数中，出现了一个陌生的关键字await——这个关键字只能够在 async 函数中使用，否则将会报错，它的意思是紧跟在其后面的
    表达式需要被等待执行结果。

    写成 generator 的话，应该是类似下面的函数：

    function * asyncLoadData (urlOne, urlTwo) {
        let dataOne = yield loadData (urlOne)
        let dataTwo = yield loadData (urlTwo)
    }

    generator 和 async 的区别：
    1.generator 函数需要通过调用next()方法，才能往后执行到下一个yield，但是 async 函数却不需要，它能够自动向后执行
    2.async，更容易理解，写法很清晰
    3.yield命令后面只能跟随Trunk或Promise，但是await后面除了可以是Promise，也可以是普通类型，但是这样就和同步没有任何区别了
    4.返回的是一个遍历器对象，而 async 返回的是一个 Promise 对象
    
    async 返回一个Promise，因此这个函数可以通过then添加回调函数，async 函数中 return 的结果将作为回调的参数，当 async 函数
    内部抛出一个错误时，也会被 catch 到

    当一个 async 函数中有多个await时，这些 await是继发执行的，只有当前一个await后面的方法执行完毕后，才会执行下一个
    如果我们前后的方法由依赖关系，继发执行是没有问题的，但是如果并没有任何关系的话，这样就会很耗时，所以需要让这些await命令同时执行，也就是并发执行
    let [res1, res2] = await Promise.all([func1(), func2()])

    let func1Promise = func1() 
    let func2Promise = func2() 
    let res1 = await func1Promise 
    let res2 = await func2Promise

