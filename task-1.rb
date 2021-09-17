# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

def work(filename = 'data.txt')

  file_lines = File.read(filename).split("\n")

  users = {}
  total_users = 0
  total_sessions = 0

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      total_users += 1
      users[cols[1]] = {name: "#{cols[2]} #{cols[3]}", sessions_count: 0, total_time: 0, longest_session: 0, browsers: [], dates: []}
    elsif cols[0] == 'session'
      total_sessions += 1
      users[cols[1]][:sessions_count] += 1
      time = cols[4].to_i
      users[cols[1]][:total_time] += time
      current_longest_session = users[cols[1]][:longest_session] 
      users[cols[1]][:longest_session] = current_longest_session > time ? current_longest_session : time
      users[cols[1]][:browsers] << cols[3]
      users[cols[1]][:dates] = (users[cols[1]][:dates] + [cols[5]]).uniq
    end
  end

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  report = {}

  report[:totalUsers] = total_users

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = users.values.map{ |user| user[:browsers].uniq}.flatten.uniq.sort

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = total_sessions

  report['allBrowsers'] = uniqueBrowsers.map{|browser| browser.upcase}.join(',')

  # Статистика по пользователям
  user_stats = {}

  users.each do |id, user|
    user_stats[user[:name]] = {
      "sessionsCount": user[:sessions_count],
      "totalTime": "#{user[:total_time]} min.",
      "longestSession": "#{user[:longest_session]} min.",
      "browsers": user[:browsers].map{|user_browser| user_browser.upcase}.sort.join(', ') ,
      "usedIE": user[:browsers].any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      "alwaysUsedChrome": user[:browsers].all? { |b| b.upcase =~ /CHROME/ } ,
      "dates": user[:dates].sort{|a,b| b <=> a }
    }
  end

  report['usersStats'] = user_stats

  File.write('result.json', "#{report.to_json}\n")
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data.txt',
'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    work
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
