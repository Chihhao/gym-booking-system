/**
 * =================================================================
 * Manager-Utils.js
 * -----------------------------------------------------------------
 * 這是一個共用函式庫，提供給所有 manager-*.html 頁面使用。
 * 主要包含：
 * 1. Supabase Client 初始化
 * 2. 全域通知 Modal (showNotification)
 * 3. 課堂編輯 Modal 的所有相關邏輯 (open, close, save, delete)
 * 4. 載入表單所需資料 (課程、教練) 的函式
 * =================================================================
 */

// --- 從 config.js 讀取設定並建立 Supabase Client ---
const { createClient } = supabase;
const supabaseClient = createClient(AppConfig.SUPABASE_URL, AppConfig.SUPABASE_ANON_KEY);

// --- 全域變數 ---
let managerFormData = null; // 儲存課程和教練列表

// --- 全域卡片式通知函式 ---
function showNotification(message, type = 'info') {
    const modal = document.getElementById('notification-modal');
    if (!modal) return; // 如果頁面沒有這個 modal，就直接返回

    const titleEl = document.getElementById('notification-title');
    const messageEl = document.getElementById('notification-message');
    const closeBtn = document.getElementById('notification-close-btn');

    messageEl.textContent = message;
    closeBtn.className = 'btn'; // 重設按鈕 class

    switch (type) {
        case 'success':
            titleEl.textContent = '操作成功';
            closeBtn.classList.add('btn-success');
            break;
        case 'error':
            titleEl.textContent = '發生錯誤';
            closeBtn.classList.add('btn-danger');
            break;
        default:
            titleEl.textContent = '通知';
            closeBtn.classList.add('btn-secondary');
            break;
    }
    modal.classList.add('active');
}

// --- 課堂 Modal 相關函式 ---

function closeClassModal() {
    const modal = document.getElementById('class-modal');
    if (modal) {
        modal.classList.remove('active');
    }
}

async function handleSaveClass(event, callback) {
    event.preventDefault();
    const form = event.target;
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalBtnText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.textContent = '儲存中...';

    const params = {
        p_class_id: document.getElementById('form-class-id').value,
        p_class_date: document.getElementById('form-class-date').value,
        p_start_time: document.getElementById('form-start-time').value,
        p_end_time: document.getElementById('form-end-time').value,
        p_course_id: document.getElementById('form-course-id').value,
        p_class_name: document.getElementById('form-class-name').value,
        p_coach_id: document.getElementById('form-coach-id').value,
        p_max_students: parseInt(document.getElementById('form-max-students').value, 10)
    };

    try {
        const { data, error } = await supabaseClient.rpc('save_class', params);
        if (error) throw error;

        const result = data[0];
        showNotification(result.message, result.status);

        if (result.status === 'success') {
            closeClassModal();
            if (typeof callback === 'function') {
                callback(); // 呼叫回呼函式 (例如：重新載入課表)
            }
        }

    } catch (error) {
        console.error('儲存課堂時發生錯誤:', error);
        showNotification('操作失敗，請檢查網路或聯繫開發者。', 'error');
    } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = originalBtnText;
    }
}

async function handleDeleteClass(event, callback, showConfirmationFunc) {
    const classId = document.getElementById('form-class-id').value;
    // 修正：使用傳入的 showConfirmation 函式
    const confirmed = await showConfirmationFunc('您確定要刪除這個課堂嗎？<br>此操作無法復原。', {
        confirmText: '確認刪除',
        confirmButtonClass: 'btn-danger'
    });
    if (!confirmed) return;

    const deleteBtn = document.getElementById('delete-class-btn');
    const originalBtnText = deleteBtn.textContent;
    deleteBtn.disabled = true;
    deleteBtn.textContent = '刪除中...';

    try {
        const { data, error } = await supabaseClient.rpc('delete_class', { p_class_id: classId });
        if (error) throw error;

        const result = data[0];
        showNotification(result.message, result.status);

        if (result.status === 'success') {
            closeClassModal();
            if (typeof callback === 'function') {
                callback(); // 呼叫回呼函式 (例如：重新載入課表)
            }
        }
    } catch (error) {
        console.error('刪除課堂時發生錯誤:', error);
        showNotification('操作失敗，請檢查網路或聯繫開發者。', 'error');
    } finally {
        deleteBtn.disabled = false;
        deleteBtn.textContent = originalBtnText;
    }
}

async function loadManagerFormData() {
    if (managerFormData) return; // 如果資料已存在，直接返回
    try {
        const { data: result, error } = await supabaseClient.rpc('get_manager_form_data');
        if (error) throw error;
        if (result.status !== 'success') throw new Error(result.message);
        managerFormData = result;
    } catch (error) {
        console.error('載入管理表單資料失敗:', error);
        showNotification(`載入表單選項失敗: ${error.message}`, 'error');
        // 在下拉選單中顯示錯誤
        const courseSelect = document.getElementById('form-course-id');
        const coachSelect = document.getElementById('form-coach-id');
        if(courseSelect) courseSelect.innerHTML = `<option value="">載入失敗</option>`;
        if(coachSelect) coachSelect.innerHTML = `<option value="">載入失敗</option>`;
    }
}

function populateFormDropdowns() {
    if (!managerFormData) return;

    const courseSelect = document.getElementById('form-course-id');
    const coachSelect = document.getElementById('form-coach-id');

    if (!courseSelect || !coachSelect) return;

    courseSelect.innerHTML = '<option value="">-- 請選擇課程 --</option>';
    managerFormData.courses.forEach(course => {
        const option = new Option(`${course.courseName} (${course.courseId})`, course.courseId);
        courseSelect.add(option);
    });

    coachSelect.innerHTML = '<option value="">-- 請選擇教練 --</option>';
    managerFormData.coaches.forEach(coach => {
        const option = new Option(coach.coachName, coach.coachId);
        coachSelect.add(option);
    });
}