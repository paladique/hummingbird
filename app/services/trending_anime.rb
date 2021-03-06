class TrendingAnime
  STREAM_KEY = "trending_anime"
  HALF_LIFE  = 7.days.to_i
  EPOCH      = Date.new(2020, 1, 1).to_time.to_i

  def self.vote(anime_id)
    $redis.with do |conn|
      conn.zincrby STREAM_KEY, 2.0**((Time.now.to_i - EPOCH) / HALF_LIFE), anime_id
    end
    trim(STREAM_KEY, 10000) if rand < 0.1
  end

  def self.get(limit=5)
    $redis.with do |conn|
      conn.zrevrange(STREAM_KEY, 0, limit-1).map {|x| x.to_i }
    end
  end

  def self.trim(key, n)
    $redis.with {|conn| conn.zremrangebyrank(key, 0, -n) }
  end

  def self.list(count = 5)
    Anime.where(id: get(count))
  end
end
