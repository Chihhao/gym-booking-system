/**
 * 渲染共用的頁首和頁尾。
 * 這個函式會動態地將 HTML 和 CSS 插入到頁面中。
 */
function renderHeaderAndFooter() {
    const studioName = 'WALLY STUDIO | 瓦力自由教練工作室';

    // 1. 分別定義 Header (左對齊) 和 Footer (右對齊) 的 HTML 結構
    const headerBarHtml = `
        <div class="common-bar header-bar">
            <div class="bar-block-start"></div>
            <div class="bar-text">${studioName}</div>
            <div class="bar-block-end"></div>
        </div>
    `;

    const footerBarHtml = `
        <div class="common-bar footer-bar">
            <div class="bar-block-end"></div>
            <div class="bar-text">${studioName}</div>
            <div class="bar-block-start"></div>
        </div>
    `;

    // 2. 定義共用元件的 CSS 樣式
    const styles = `
        /* 新增：為主要內容容器加上統一的上下間距 */
        .main-container {
            padding-top: 20px;
            padding-bottom: 30px;
        }
        .common-bar {
            /* 容器本身是透明的，並使用 flex 佈局 */
            display: flex;
            align-items: center;
            height: 10px;
            width: 100%;
            position: fixed;          /* 固定在畫面上 */
            left: 0;
            z-index: 100;             /* 確保在最上層 */
            box-sizing: border-box;
            pointer-events: none;     /* 讓滑鼠可以穿透，避免擋到內容 */
        }
        .header-bar {
            top: 0; /* Header 固定在頂部 */
        }
        .footer-bar {
            bottom: 0; /* Footer 固定在底部 */
        }
        .bar-block-start, .bar-block-end {
            background-color: #fcc419; /* 專案主題黃色 */
            height: 4px; /* 調整高度與文字大小 (font-size) 一致 */
        }
        .bar-block-start {
            width: 20px;
            flex-shrink: 0; /* 防止被壓縮 */
        }
        .bar-block-end {
            flex-grow: 1; /* 填滿剩餘空間 */
        }
        .bar-text {
            color: #fcc419; /* 黃色文字 */
            font-weight: 600;
            font-size: 12px;
            line-height: 10px;
            padding: 0 10px; /* 讓文字和色塊之間有些間距 */
            white-space: nowrap; /* 防止文字換行 */
        }
    `;

    // 3. 將樣式和 HTML 插入到 DOM 中
    document.head.insertAdjacentHTML('beforeend', `<style>${styles}</style>`);
    document.body.insertAdjacentHTML('afterbegin', headerBarHtml);
    document.body.insertAdjacentHTML('beforeend', footerBarHtml);
}