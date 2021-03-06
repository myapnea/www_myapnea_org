# frozen_string_literal: true

require "test_helper"

# Test that notifications can be viewed and marked as read.
class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
    @admin = users(:admin)
  end

  test "should get index" do
    login(@regular)
    get notifications_url
    assert_response :success
  end

  test "should get all read index" do
    login(@regular)
    get notifications_url, params: { all: "1" }
    assert_response :success
  end

  test "should show blog post reply notification" do
    login(@regular)
    get notification_url(notifications(:broadcast_reply_two))
    notifications(:broadcast_reply_two).reload
    assert_equal true, notifications(:broadcast_reply_two).read?
    assert_redirected_to notifications(:broadcast_reply_two).reply
  end

  test "should show export notification" do
    login(@admin)
    notification = notifications(:export)
    get notification_url(notification)
    notification.reload
    assert_equal true, notification.read?
    assert_redirected_to notification.admin_export
  end

  test "should show blank notification and redirect" do
    login(@regular)
    get notification_url(notifications(:blank))
    notifications(:blank).reload
    assert_equal true, notifications(:blank).read?
    assert_redirected_to notifications_url
  end

  test "should not show notification without valid id" do
    login(@regular)
    get notification_url(-1)
    assert_redirected_to notifications_url
  end

  test "should update notification" do
    login(@regular)
    patch notification_url(notifications(:broadcast_reply_two), format: "js"), params: {
      notification: { read: true }
    }
    notifications(:broadcast_reply_two).reload
    assert_equal true, notifications(:broadcast_reply_two).read?
    assert_response :success
  end

  test "should mark all as read" do
    login(@regular)
    patch mark_all_as_read_notifications_url(format: "js"), params: {
      broadcast_id: broadcasts(:published).id
    }
    assert_equal 0, @regular.notifications.where(broadcast_id: broadcasts(:published), read: false).count
    assert_response :success
  end

  test "should not mark all as read without broadcast or topic id" do
    login(@regular)
    assert_difference("Notification.where(read: false).count", 0) do
      patch mark_all_as_read_notifications_url(format: "js")
    end
    assert_response :success
  end
end
