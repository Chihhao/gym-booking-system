/**
 * 渲染共用的頁首和頁尾。
 * 這個函式會動態地將 HTML 和 CSS 插入到頁面中。
 */
function renderHeaderAndFooter() {
    const studioName = 'WALLY STUDIO | Wally 自由教練工作室';

    // 1. 定義共用元件的 HTML 結構
    const headerHtml = `<div class="common-bar">${studioName}</div>`;
    const footerHtml = `<div class="common-bar">${studioName}</div>`;

    // 2. 定義共用元件的 CSS 樣式
    const styles = `
        .common-bar {
            background-color: #fcc419; /* 專案主題黃色 */
            color: #212529;           /* 深色文字 */
            text-align: center;
            font-weight: 600;
            font-size: 11px;          /* 調整字體大小以適應高度 */
            line-height: 20px;        /* 垂直置中文字 */
            height: 20px;
            width: 100%;
            position: fixed;          /* 固定在畫面上 */
            left: 0;
            z-index: 100;             /* 確保在最上層 */
            box-sizing: border-box;
        }
        .common-bar:first-of-type {
            top: 0; /* Header 固定在頂部 */
        }
        .common-bar:last-of-type {
            bottom: 0; /* Footer 固定在底部 */
        }
    `;

    // 3. 將樣式和 HTML 插入到 DOM 中
    document.head.insertAdjacentHTML('beforeend', `<style>${styles}</style>`);
    document.body.insertAdjacentHTML('afterbegin', headerHtml);
    document.body.insertAdjacentHTML('beforeend', footerHtml);
}