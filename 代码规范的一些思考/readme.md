# 代码规范的意义

1， 对代码整洁规范缺乏重视和追求，是职业素养的缺失，也是基本功的缺失。

2，追求整洁的代码会使您变成更好的程序员。

3，C++的发明人认为，整洁规范的代码，会使得错误无处隐藏。



# 对于PHP而言，可以使用的工具

1，PSR 2.0是一个规范，需要被遵守，具体可以参考 https://segmentfault.com/a/1190000002521620

2，我们可以使用PHP_CodeSniffer, 使用方法大致可以参考

https://blog.csdn.net/ownfire/article/details/74897823

3，每次提交代码之前，请用PHP_CodeSniffer来检查一下你的代码。



# 可以参考的书

1，强烈推荐《clean code》一书。我已经把这本书的PDF版本也一起放在了github上。这本书的第一章到第九章应该仔细研读，后面几章可以选择浏览。

2，《clean code》这本书在国内有很多粉丝，因而有不少读后感，大家也可以参考， 例如 https://book.douban.com/review/5613396/， 以及 https://www.cnblogs.com/lyy-2016/p/6118040.html

3，书中的观点未必完全正确，有少量内容存有争议，但是有思考才会进步。



# 代码例子

## 不好的命名

```php
int i=0；// i没有意义，不如改成 studentAmount 或者其他有意义的名字

if （$index == 4） return true; //4有什么特殊含义？不如改成一个有意义的名字，可以把 4 改为 MAX_POSSIBLE_AMOUNT，而且这样的常数，便于检索

var accountList; // accountList可能会误导，特别是在java中，List是一种容器，其他人可能会理所当然认为这个变量是一个List类型。

public static void copyArray(Array a1, Array a2) // 如果把a1，a2重命名为source和destination，这个函数就会非常清楚明白

var Product;
var ProductInfo; //  阅读者会非常困扰这两个变量有何不同

getActiveAccount();
getActiveAccounts(); //阅读者会非常困挠两个函数应该调用哪一个

class DtaRcord{}; //这个不是合适的英语，不如改成DataRecord

//总结，变量、函数、类的命名中，清楚明确才是王道

```



##函数不够短小

每个函数只应该做一件事，因此，函数在20行左右为佳

```PHP
// 接收查询的参数
$minDate = trim($this->input->get_post('startDate', true));
$maxDate = trim($this->input->get_post('endDate', true));
$gameId = trim($this->input->get_post('gameId', true));
$adPositionId = trim($this->input->get_post('adPositionId', true));
$orderField = trim($this->input->get_post('orderField', true));
$order = trim($this->input->get_post('order', true));
$page = intval($this->input->get_post('page', true));
$pageSize = intval($this->input->get_post('pageSize', true));

if (!$order || !in_array($order, array('asc', 'desc'))) {
    $order = 'desc';
}

if (!$orderField || !isset($this->_fieldsMappingArray[$orderField])) {
    $searchParam['sort_by'] = 'date';
} else {
    $searchParam['sort_by'] = $this->_fieldsMappingArray[$orderField];
}

if (!$minDate) {
    $minDate = date('Y-m-d', strtotime('-1 day'));
}

if (!$maxDate) {
    $maxDate = date('Y-m-d');
}

if (strtotime($minDate)) {
    $searchParam['minDate'] = strtotime($minDate . ' 00:00:00');
}

if (strtotime($maxDate)) {
    $searchParam['maxDate'] = strtotime($maxDate . ' 23:59:59');
}
// .......一系列的判断

// 开始调用查询
$this->load->model('webgame_model');
$result = $this->webgame_model->getStatisData();
// 一系列组装数据
$this-view('users/webgameStatisList.php', $data);
```

这是显示一个列表的action的代码，应该优化为：

```PHP
// 接收处理查询参数
$params = $this->getSearchFileds($this->searchFiledOptions, $_REQUEST);

// 判断参数合法性
if ($tips = $this->checkParam()) {
    $this->message->tips($tips);
}

// 查询获取游戏统计数据
$statis = $this->_searchWebGameStatis($params);

$statis['searchs'] = $params;

// 其他导航信息组装
$this->template->cpView('users/webGameStatis', $statis);
```

短小的函数就像是短小的文章，简单易懂



## 注释

注释本身必不可少，但是糟糕的代码加上注释，依然是糟糕的代码，好的代码不需要太多的注释，因为好的代码本身会说话，本身就很容易懂

下列是一些不好的注释

```
int $a = 1; // 因为Luke让我这么写  谁是Luke？Luke提出了怎样的要求

return true; // return true 这个纯属废话，侮辱了读者的智商



/*

很长很长的一段注释，比短篇小说还要长

….

….

….

….

*/

public class GetAllStudents(){};


/* 这是软件的名字 */
private String name；
/* 这是软件的版本 */
private String version；
/* 这是软件的license */
private String license； 

//以上三行代码，注释没有任何意义，废话连篇

```



## 不停的重复自己

Don't Repeat Yourself， DRY原则必须被遵守。 DRY原则也不能被滥用

https://www.jianshu.com/p/87fc1079d596。这片文章在知乎上有大讨论。





