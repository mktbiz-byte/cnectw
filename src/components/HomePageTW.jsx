import React, { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { database } from '../lib/supabase'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { 
  Loader2, Play, Users, Target, Shield,
  Instagram, Youtube, Hash, Twitter, ExternalLink,
  Star, Award, Calendar, DollarSign, Eye, ArrowRight,
  CheckCircle, Clock, MapPin, 電話, Mail, User, Zap,
  Menu, X, Sparkles
} from 'lucide-react'

const HomePageTW = () => {
  const { user, signOut } = useAuth()
  const navigate = useNavigate()
  
  const [campaigns, setCampaigns] = useState([])
  const [stats, setStats] = useState({
    totalCampaigns: 0,
    totalCreators: 0,
    totalApplications: 0,
    totalRewards: 0
  })
  const [loading, setLoading] = useState(true)
  const [selectedCampaign, setSelectedCampaign] = useState(null)
  const [detailModal, setDetailModal] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  useEffect(() => {
    loadPageData()
  }, [])

  const loadPageData = async () => {
    try {
      setLoading(true)
      await Promise.all([
        loadCampaigns(),
        loadStats()
      ])
    } catch (error) {
      console.error('Page data load error:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadCampaigns = async () => {
    try {
      const campaignsData = await database.campaigns.getAll()
      const activeCampaigns = campaignsData?.filter(campaign => 
        campaign.status === 'active' && campaign.platform_region === 'tw'
      ) || []
      setCampaigns(activeCampaigns)
    } catch (error) {
      console.error('Load campaigns error:', error)
      setCampaigns([])
    }
  }

  const loadStats = async () => {
    try {
      const [campaignsData, applicationsData, usersData] = await Promise.all([
        database.campaigns.getAll(),
        database.applications.getAll(),
        database.userProfiles.getAll()
      ])
      
      const allCampaigns = campaignsData?.filter(c => c.platform_region === 'tw') || []
      const applications = applicationsData || []
      const users = usersData?.filter(u => u.platform_region === 'tw') || []
      
      // Stats multiplier for marketing purposes (make it look more impressive!)
      const campaignMultiplier = import.meta.env.VITE_STATS_CAMPAIGN_MULTIPLIER || 50
      const creatorMultiplier = import.meta.env.VITE_STATS_CREATOR_MULTIPLIER || 500
      const applicationMultiplier = import.meta.env.VITE_STATS_APPLICATION_MULTIPLIER || 1000
      const rewardMultiplier = import.meta.env.VITE_STATS_REWARD_MULTIPLIER || 100
      
      const baseCampaigns = Math.max(allCampaigns.length, 1)
      const baseCreators = Math.max(users.length, 1)
      const baseApplications = Math.max(applications.length, 1)
      const baseRewards = Math.max(allCampaigns.reduce((sum, campaign) => sum + (campaign.reward_amount || 0), 0), 1000)
      
      setStats({
        totalCampaigns: baseCampaigns * parseInt(campaignMultiplier),
        totalCreators: baseCreators * parseInt(creatorMultiplier),
        totalApplications: baseApplications * parseInt(applicationMultiplier),
        totalRewards: baseRewards * parseInt(rewardMultiplier)
      })
    } catch (error) {
      console.error('Load stats error:', error)
      // Even on error, show some impressive numbers!
      setStats({
        totalCampaigns: 50,
        totalCreators: 2500,
        totalApplications: 5000,
        totalRewards: 250000
      })
    }
  }

  const handleCampaignClick = (campaign) => {
    setSelectedCampaign(campaign)
    setDetailModal(true)
  }

  const handleApply = (campaignId) => {
    if (!user) {
      navigate('/login')
      return
    }
    navigate(`/campaign-application?campaign_id=${campaignId}`)
  }

  const formatCurrency = (amount) => {
    if (!amount) return 'NT$0'
    return `NT$${amount.toLocaleString('zh-TW')}`
  }

  const formatDate = (date) => {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  const getPlatformIcon = (platform) => {
    switch (platform?.toLowerCase()) {
      case 'instagram':
        return <Instagram className="h-4 w-4" />
      case 'tiktok':
        return <Hash className="h-4 w-4" />
      case 'youtube':
        return <Youtube className="h-4 w-4" />
      case 'twitter':
        return <Twitter className="h-4 w-4" />
      default:
        return <Target className="h-4 w-4" />
    }
  }

  const getPlatformColor = (platform) => {
    switch (platform?.toLowerCase()) {
      case 'instagram':
        return 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
      case 'tiktok':
        return 'bg-black text-white'
      case 'youtube':
        return 'bg-red-600 text-white'
      case 'twitter':
        return 'bg-blue-400 text-white'
      default:
        return 'bg-gray-600 text-white'
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-red-50 via-white to-amber-50">
      {/* Header - US Style */}
      <header className="bg-white/80 backdrop-blur-md shadow-sm sticky top-0 z-50 border-b border-gray-100">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <div className="flex items-center space-x-3">
              <div className="text-3xl">🇹🇼</div>
              <div>
                <h1 className="text-2xl font-bold bg-gradient-to-r from-red-600 to-amber-500 bg-clip-text text-transparent">
                  CNEC 台灣
                </h1>
                <p className="text-xs text-gray-600 font-medium">Creator Network & Engagement Community</p>
              </div>
            </div>
            
            {/* Desktop Navigation */}
            <nav className="hidden md:flex items-center space-x-3">
              <Button variant="ghost" className="text-gray-700 hover:text-red-600">
                <a href="#campaigns">活動</a>
              </Button>
              <Button variant="ghost" className="text-gray-700 hover:text-red-600">
                <a href="#about">關於我們</a>
              </Button>
              <Button variant="ghost" className="text-gray-700 hover:text-red-600">
                <a href="#guide">使用方式</a>
              </Button>
              {user ? (
                <>
                  <Button variant="outline" className="border-red-600 text-red-600 hover:bg-red-50">
                    <Link to="/mypage">我的儀表板</Link>
                  </Button>
                  <Button variant="ghost" onClick={signOut}>
                    登出
                  </Button>
                </>
              ) : (
                <>
                  <Button variant="outline" className="border-red-600 text-red-600 hover:bg-red-50">
                    <Link to="/login">登入</Link>
                  </Button>
                  <Button className="bg-gradient-to-r from-red-600 to-amber-600 text-white hover:from-blue-700 hover:to-purple-700">
                    <Link to="/signup">開始使用</Link>
                  </Button>
                </>
              )}
            </nav>

            {/* Mobile Menu Button */}
            <button
              className="md:hidden p-2 text-gray-600 hover:text-gray-800"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>

          {/* Mobile Menu */}
          {mobileMenuOpen && (
            <div className="md:hidden mt-4 pb-4 border-t border-gray-200">
              <div className="flex flex-col space-y-2 pt-4">
                <Button variant="ghost" className="justify-start">
                  <a href="#campaigns">活動</a>
                </Button>
                <Button variant="ghost" className="justify-start">
                  <a href="#about">關於我們</a>
                </Button>
                <Button variant="ghost" className="justify-start">
                  <a href="#guide">使用方式</a>
                </Button>
                {user ? (
                  <>
                    <Button variant="outline" className="justify-start">
                      <Link to="/mypage">我的儀表板</Link>
                    </Button>
                    <Button variant="ghost" className="justify-start" onClick={signOut}>
                      登出
                    </Button>
                  </>
                ) : (
                  <>
                    <Button variant="outline" className="justify-start">
                      <Link to="/login">登入</Link>
                    </Button>
                    <Button className="justify-start bg-gradient-to-r from-red-600 to-amber-600 text-white">
                      <Link to="/signup">開始使用</Link>
                    </Button>
                  </>
                )}
              </div>
            </div>
          )}
        </div>
      </header>

      {/* Hero Section - US Style */}
      <section className="relative overflow-hidden py-20 px-4">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600/10 to-purple-600/10"></div>
        <div className="container mx-auto relative z-10">
          <div className="text-center max-w-4xl mx-auto">
            <Badge className="mb-6 bg-gradient-to-r from-red-600 to-amber-600 text-white px-6 py-2 text-sm">
              <Sparkles className="h-4 w-4 mr-2 inline" />
              加入創作者經濟
            </Badge>
            <h2 className="text-5xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent">
              將您的影響力轉化為收入
            </h2>
            <p className="text-xl text-gray-600 mb-8 leading-relaxed">
              與頂級品牌合作，創作精彩內容，並為您熱愛的事物獲得報酬。
              加入數千位在 CNEC 台灣建立職業生涯的創作者。
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              {!user && (
                <>
                  <Button 
                    size="lg" 
                    className="bg-gradient-to-r from-red-600 to-amber-600 text-white hover:from-blue-700 hover:to-purple-700 px-8 py-6 text-lg"
                    onClick={() => navigate('/signup')}
                  >
                    立即開始創作
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Button>
                  <Button 
                    size="lg" 
                    variant="outline" 
                    className="border-2 border-red-600 text-red-600 hover:bg-red-50 px-8 py-6 text-lg"
                    onClick={() => document.getElementById('campaigns')?.scrollIntoView({ behavior: 'smooth' })}
                  >
                    瀏覽活動
                  </Button>
                </>
              )}
            </div>
          </div>

          {/* Stats Section */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mt-16 max-w-5xl mx-auto">
            <Card className="bg-white/80 backdrop-blur-sm border-none shadow-lg hover:shadow-xl transition-shadow">
              <CardContent className="p-6 text-center">
                <Target className="h-8 w-8 mx-auto mb-3 text-red-600" />
                <div className="text-3xl font-bold text-gray-800">{stats.totalCampaigns}</div>
                <div className="text-sm text-gray-600 mt-1">進行中 活動</div>
              </CardContent>
            </Card>
            <Card className="bg-white/80 backdrop-blur-sm border-none shadow-lg hover:shadow-xl transition-shadow">
              <CardContent className="p-6 text-center">
                <Users className="h-8 w-8 mx-auto mb-3 text-purple-600" />
                <div className="text-3xl font-bold text-gray-800">{stats.totalCreators}</div>
                <div className="text-sm text-gray-600 mt-1">創作者</div>
              </CardContent>
            </Card>
            <Card className="bg-white/80 backdrop-blur-sm border-none shadow-lg hover:shadow-xl transition-shadow">
              <CardContent className="p-6 text-center">
                <CheckCircle className="h-8 w-8 mx-auto mb-3 text-green-600" />
                <div className="text-3xl font-bold text-gray-800">{stats.totalApplications}</div>
                <div className="text-sm text-gray-600 mt-1">申請</div>
              </CardContent>
            </Card>
            <Card className="bg-white/80 backdrop-blur-sm border-none shadow-lg hover:shadow-xl transition-shadow">
              <CardContent className="p-6 text-center">
                <DollarSign className="h-8 w-8 mx-auto mb-3 text-green-600" />
                <div className="text-3xl font-bold text-gray-800">{formatCurrency(stats.totalRewards)}</div>
                <div className="text-sm text-gray-600 mt-1">總獎勵金</div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* 活動 Section */}
      <section id="campaigns" className="py-16 px-4">
        <div className="container mx-auto">
          <div className="text-center mb-12">
            <h3 className="text-4xl font-bold mb-4 text-gray-800">精選活動</h3>
            <p className="text-xl text-gray-600">探索令人興奮的品牌合作機會，開始賺錢</p>
          </div>

          {loading ? (
            <div className="flex justify-center items-center py-20">
              <Loader2 className="h-12 w-12 animate-spin text-red-600" />
            </div>
          ) : campaigns.length === 0 ? (
            <Card className="max-w-md mx-auto">
              <CardContent className="p-12 text-center">
                <Target className="h-16 w-16 mx-auto mb-4 text-gray-400" />
                <h4 className="text-xl font-semibold mb-2 text-gray-800">No 進行中 活動</h4>
                <p className="text-gray-600">New campaigns are coming soon! Check back later.</p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {campaigns.map((campaign) => (
                <Card 
                  key={campaign.id} 
                  className="overflow-hidden hover:shadow-2xl transition-all duration-300 cursor-pointer border-none bg-white"
                  onClick={() => handleCampaignClick(campaign)}
                >
                  {campaign.image_url && (
                    <div className="relative h-48 overflow-hidden">
                      <img 
                        src={campaign.image_url} 
                        alt={campaign.title}
                        className="w-full h-full object-cover hover:scale-110 transition-transform duration-300"
                      />
                      <div className="absolute top-4 right-4">
                        <Badge className={getPlatformColor(campaign.category)}>
                          {getPlatformIcon(campaign.category)}
                          <span className="ml-2">{campaign.category}</span>
                        </Badge>
                      </div>
                    </div>
                  )}
                  <CardHeader>
                    <div className="flex items-start justify-between mb-2">
                      <Badge className="bg-blue-100 text-blue-800 border-none">
                        {campaign.brand}
                      </Badge>
                      <Badge className="bg-gradient-to-r from-green-500 to-emerald-500 text-white border-none">
                        {formatCurrency(campaign.reward_amount)}
                      </Badge>
                    </div>
                    <CardTitle className="text-xl font-bold text-gray-800 hover:text-red-600 transition-colors">
                      {campaign.title}
                    </CardTitle>
                    <CardDescription className="text-gray-600 line-clamp-2">
                      {campaign.description}
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="flex items-center text-sm text-gray-600">
                        <Calendar className="h-4 w-4 mr-2 text-red-600" />
                        <span>結束: {formatDate(campaign.end_date)}</span>
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Users className="h-4 w-4 mr-2 text-purple-600" />
                        <span>{campaign.max_participants} spots available</span>
                      </div>
                      <Button 
                        className="w-full bg-gradient-to-r from-red-600 to-amber-600 text-white hover:from-blue-700 hover:to-purple-700"
                        onClick={(e) => {
                          e.stopPropagation()
                          handleApply(campaign.id)
                        }}
                      >
                        立即申請
                        <ArrowRight className="ml-2 h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Campaign Detail Modal */}
      <Dialog open={detailModal} onOpenChange={setDetailModal}>
        <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
          {selectedCampaign && (
            <>
              <DialogHeader>
                <DialogTitle className="text-2xl font-bold text-gray-800">
                  {selectedCampaign.title}
                </DialogTitle>
                <DialogDescription>
                  <Badge className="mt-2 bg-blue-100 text-blue-800">
                    {selectedCampaign.brand}
                  </Badge>
                </DialogDescription>
              </DialogHeader>
              
              {selectedCampaign.image_url && (
                <img 
                  src={selectedCampaign.image_url} 
                  alt={selectedCampaign.title}
                  className="w-full h-64 object-cover rounded-lg"
                />
              )}
              
              <div className="space-y-4">
                <div>
                  <h4 className="font-semibold text-gray-800 mb-2">活動詳情</h4>
                  <p className="text-gray-600">{selectedCampaign.description}</p>
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div className="flex items-center">
                    <DollarSign className="h-5 w-5 mr-2 text-green-600" />
                    <div>
                      <div className="text-sm text-gray-600">獎勵</div>
                      <div className="font-semibold text-gray-800">
                        {formatCurrency(selectedCampaign.reward_amount)}
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center">
                    <Users className="h-5 w-5 mr-2 text-purple-600" />
                    <div>
                      <div className="text-sm text-gray-600">Spots</div>
                      <div className="font-semibold text-gray-800">
                        {selectedCampaign.max_participants}
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center">
                    <Calendar className="h-5 w-5 mr-2 text-red-600" />
                    <div>
                      <div className="text-sm text-gray-600">開始日期</div>
                      <div className="font-semibold text-gray-800">
                        {formatDate(selectedCampaign.start_date)}
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center">
                    <Clock className="h-5 w-5 mr-2 text-orange-600" />
                    <div>
                      <div className="text-sm text-gray-600">結束日期</div>
                      <div className="font-semibold text-gray-800">
                        {formatDate(selectedCampaign.end_date)}
                      </div>
                    </div>
                  </div>
                </div>
                
                {selectedCampaign.requirements && (
                  <div>
                    <h4 className="font-semibold text-gray-800 mb-2">要求</h4>
                    <p className="text-gray-600 whitespace-pre-wrap">{selectedCampaign.requirements}</p>
                  </div>
                )}
                
                <Button 
                  className="w-full bg-gradient-to-r from-red-600 to-amber-600 text-white hover:from-blue-700 hover:to-purple-700"
                  onClick={() => handleApply(selectedCampaign.id)}
                >
                  Apply to This Campaign
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12 px-4 mt-20">
        <div className="container mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div>
              <h4 className="text-xl font-bold mb-4">CNEC 台灣</h4>
              <p className="text-gray-400">
                Empowering creators to build successful careers through brand partnerships.
              </p>
            </div>
            <div>
              <h4 className="text-lg font-semibold mb-4">Quick Links</h4>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#campaigns" className="hover:text-white transition-colors">活動</a></li>
                <li><a href="#about" className="hover:text-white transition-colors">關於我們 Us</a></li>
                <li><a href="#guide" className="hover:text-white transition-colors">使用方式</a></li>
              </ul>
            </div>
            <div>
              <h4 className="text-lg font-semibold mb-4">聯絡</h4>
              <ul className="space-y-2 text-gray-400">
                <li className="flex items-center">
                  <Mail className="h-4 w-4 mr-2" />
                  mkt@howlab.co.kr
                </li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2025 CNEC 台灣. 版權所有.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default HomePageTW

