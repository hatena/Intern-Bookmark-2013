/**
 * XHR でサーバーからブックマークの情報を取得してブックマーク一覧を更新。
 */
function updateContent() {

    var contentElem = document.getElementById("content");
    contentElem.innerHTML = "";

    function createBookmarkItemElem(e) {
        var itemElem = document.createElement("div");
        itemElem.className = "bookmark";
        // ページタイトル
        var entryElem = itemElem.appendChild(document.createElement("div"));
        var anchorElem = entryElem.appendChild(document.createElement("a"));
        anchorElem.textContent = e.entry.title || e.entry.url;
        anchorElem.href = e.entry.url;
        // コメント
        itemElem.appendChild(document.createElement("span")).textContent = e.comment;
        return itemElem;
    }

    function showProgress() {
        contentElem.innerHTML = "<div class=\"message\">ブックマーク一覧を読み込んでいます。</div>"
    }

    function showError() {
        contentElem.innerHTML = "<div class=\"message\">ブックマーク一覧を読み込めませんでした。</div>"
    }

    var xhr = new XMLHttpRequest();
    xhr.open("GET", "/api/bookmarks", true);
    xhr.addEventListener("load", function (evt) {
        contentElem.innerHTML = "";
        var xhr = evt.currentTarget;
        if (xhr.status === 200) {
            var bookmarksInfo = JSON.parse(xhr.responseText);
            bookmarksInfo.bookmarks.forEach(function (e) {
                contentElem.appendChild(createBookmarkItemElem(e));
            });
        } else {
            showError();
        }
    }, false);
    xhr.send();
    showProgress();

}

/**
 * ブックマーク追加フォーム。
 */
function BookmarkAddingForm(formElem) {
    this._elem = formElem;
    this._submitButton = formElem.querySelector("input[type='submit']");
    this._submitButtonDefaultLabel = this._submitButton.value;
    var that = this;
    formElem.addEventListener("submit", function (evt) {
        that.sendAddingRequest();
        evt.preventDefault();
    });
}
/**
 * フォームに入力された値を元にブックマーク追加する。
 */
BookmarkAddingForm.prototype.sendAddingRequest = function () {
    var that = this;
    var submitButton = this._submitButton;
    var formData = new FormData(this._elem);
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "/api/bookmark", true);
    xhr.addEventListener("load", function (evt) {
        var xhr = evt.currentTarget;
        if (xhr.status === 200) {
            that._elem.reset();
            // ブックマーク追加処理が完了したらリストを更新
            updateContent();
        } else {
            alert("ブックマーク追加に失敗: " + xhr.responseText);
        }
    }, false);
    xhr.addEventListener("loadend", function (evt) {
        submitButton.disabled = false;
        submitButton.value = that._submitButtonDefaultLabel;
    }, false);
    xhr.send(formData);
    submitButton.disabled = true;
    submitButton.value = "送信中";
};

// ページ読み込み時の初期化処理
document.addEventListener("DOMContentLoaded", function (evt) {
    updateContent();
    new BookmarkAddingForm(document.getElementById("bookmark-adding-form"));
}, false);
