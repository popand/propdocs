"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import {
  Home,
  Calendar,
  Plus,
  Star,
  Phone,
  Filter,
  Zap,
  Droplets,
  Wind,
  BarChart3,
  Wrench,
  Settings,
  Bell,
  Search,
  CheckCircle,
  Circle,
  Users,
  FileText,
  Activity,
  HelpCircle,
  ChevronUp,
  ExternalLink,
  ChevronDown,
  ChevronRight,
  MapPin,
  Clock,
  AlertTriangle,
} from "lucide-react"

interface Asset {
  id: number
  name: string
  category: string
  status: string
  nextMaintenance: string
  icon: any
  value: string
  efficiency: number
  installDate: string
  warranty: string
  lastService: string
  model: string
  contractor: string
  notes: string
  maintenanceHistory: Array<{
    date: string
    service: string
    cost: string
    contractor: string
  }>
}

export default function HomeServiceDashboard() {
  const [activeView, setActiveView] = useState("overview")
  const [selectedAsset, setSelectedAsset] = useState<number | null>(null)
  const [showScheduleModal, setShowScheduleModal] = useState(false)
  const [selectedAssetForSchedule, setSelectedAssetForSchedule] = useState<number | null>(null)

  const sidebarItems = [
    { icon: Home, label: "Overview", id: "overview" },
    { icon: Wrench, label: "Assets", id: "assets" },
    { icon: Calendar, label: "Maintenance", id: "maintenance" },
    { icon: Users, label: "Contractors", id: "contractors" },
    { icon: BarChart3, label: "Analytics", id: "analytics" },
    { icon: FileText, label: "Reports", id: "reports" },
    { icon: Settings, label: "Settings", id: "settings" },
    { icon: HelpCircle, label: "Help", id: "help" },
  ]

  const actionItems = [
    { id: 1, text: "Complete property onboarding", completed: true },
    { id: 2, text: "Set up maintenance alerts", completed: true },
    { id: 3, text: "Add your first asset", completed: true },
    { id: 4, text: "Schedule initial inspection", completed: false },
  ]

  const homeDetails = {
    address: "1234 Maple Street, Springfield, IL 62701",
    yearBuilt: 1995,
    squareFootage: 2400,
    bedrooms: 4,
    bathrooms: 3,
    propertyValue: "$485,000",
    lastAppraisal: "March 2023",
    maintenanceScore: 87,
    totalAssets: 24,
    upcomingTasks: 3,
  }

  const assets: Asset[] = [
    {
      id: 1,
      name: "HVAC System",
      category: "Climate Control",
      status: "Excellent",
      nextMaintenance: "Feb 15, 2024",
      icon: Wind,
      value: "$12,000",
      efficiency: 94,
      installDate: "June 2018",
      warranty: "5 years (expires June 2023)",
      lastService: "December 2023",
      model: "Carrier Infinity 19VS",
      contractor: "Mike's HVAC Services",
      notes: "Annual filter replacement and system inspection completed. Running efficiently.",
      maintenanceHistory: [
        { date: "Dec 2023", service: "Annual inspection", cost: "$150", contractor: "Mike's HVAC" },
        { date: "Jun 2023", service: "Filter replacement", cost: "$45", contractor: "Mike's HVAC" },
        { date: "Dec 2022", service: "Annual inspection", cost: "$140", contractor: "Mike's HVAC" },
      ],
    },
    {
      id: 2,
      name: "Water Heater",
      category: "Plumbing",
      status: "Needs Attention",
      nextMaintenance: "Jan 30, 2024",
      icon: Droplets,
      value: "$3,500",
      efficiency: 78,
      installDate: "March 2020",
      warranty: "10 years (expires March 2030)",
      lastService: "August 2023",
      model: "Rheem Performance Plus 50 Gal",
      contractor: "PlumbPro Solutions",
      notes: "Temperature fluctuations reported. Needs inspection for potential thermostat issues.",
      maintenanceHistory: [
        { date: "Aug 2023", service: "Routine maintenance", cost: "$120", contractor: "PlumbPro" },
        { date: "Mar 2022", service: "Anode rod replacement", cost: "$180", contractor: "PlumbPro" },
      ],
    },
    {
      id: 3,
      name: "Electrical Panel",
      category: "Electrical",
      status: "Good",
      nextMaintenance: "Mar 10, 2024",
      icon: Zap,
      value: "$2,800",
      efficiency: 88,
      installDate: "January 2019",
      warranty: "20 years (expires January 2039)",
      lastService: "September 2023",
      model: "Square D Homeline 200A",
      contractor: "ElectricMax",
      notes: "All circuits functioning properly. Scheduled for routine safety inspection.",
      maintenanceHistory: [
        { date: "Sep 2023", service: "Safety inspection", cost: "$200", contractor: "ElectricMax" },
        { date: "Jan 2022", service: "Circuit testing", cost: "$150", contractor: "ElectricMax" },
      ],
    },
  ]

  const handleScheduleMaintenance = (assetId: number) => {
    setSelectedAssetForSchedule(assetId)
    setShowScheduleModal(true)
  }

  const handleCloseModal = () => {
    setShowScheduleModal(false)
    setSelectedAssetForSchedule(null)
  }

  const ScheduleModal = () => {
    if (!showScheduleModal || !selectedAssetForSchedule) return null

    const asset = assets.find((a) => a.id === selectedAssetForSchedule)

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle>Schedule Maintenance</CardTitle>
            <p className="text-sm text-gray-600">{asset?.name}</p>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Service Type</label>
              <select className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                <option>Routine Inspection</option>
                <option>Repair Service</option>
                <option>Emergency Service</option>
                <option>Replacement</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Preferred Date</label>
              <input
                type="date"
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Priority</label>
              <select className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                <option>Low</option>
                <option>Medium</option>
                <option>High</option>
                <option>Emergency</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Notes</label>
              <textarea
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                rows={3}
                placeholder="Describe the issue or service needed..."
              />
            </div>
            <div className="flex space-x-3 pt-4">
              <Button onClick={handleCloseModal} variant="outline" className="flex-1 bg-transparent">
                Cancel
              </Button>
              <Button onClick={handleCloseModal} className="flex-1">
                Schedule Service
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <div className="w-16 bg-white border-r border-gray-200 flex flex-col items-center pt-20 pb-4 space-y-4">
        <div className="flex-1 flex flex-col space-y-2">
          {sidebarItems.map((item) => (
            <button
              key={item.id}
              onClick={() => setActiveView(item.id)}
              className={`w-10 h-10 rounded-lg flex items-center justify-center transition-colors ${
                activeView === item.id
                  ? "bg-gray-100 text-gray-900"
                  : "text-gray-500 hover:bg-gray-50 hover:text-gray-700"
              }`}
              title={item.label}
            >
              <item.icon className="w-5 h-5" />
            </button>
          ))}
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col">
        {/* Header - Overlapping Sidebar */}
        <header className="bg-white border-b border-gray-200 px-6 py-4 relative z-10 -ml-16 pl-22">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              {/* Logo and App Name */}
              <div className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                  <Home className="w-4 h-4 text-white" />
                </div>
                <h1 className="text-xl font-semibold text-gray-900">PropDocs</h1>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              <Button variant="outline" size="sm">
                <ChevronUp className="w-4 h-4 mr-2" />
                Upgrade
              </Button>
              <Button size="sm">
                <Plus className="w-4 h-4 mr-2" />
                Add Asset
              </Button>
              <Button variant="ghost" size="sm">
                <Bell className="w-4 h-4" />
              </Button>
              <Avatar className="w-8 h-8">
                <AvatarFallback className="bg-gray-100 text-gray-600 text-sm">AH</AvatarFallback>
              </Avatar>
            </div>
          </div>
        </header>

        {/* Content */}
        <main className="flex-1 p-6 overflow-auto">
          {activeView === "overview" && (
            <div className="max-w-7xl mx-auto space-y-6">
              {/* Welcome Section */}
              <div className="flex items-center space-x-4">
                <Avatar className="w-12 h-12">
                  <AvatarFallback className="bg-blue-600 text-white">AH</AvatarFallback>
                </Avatar>
                <div>
                  <p className="text-sm text-gray-600">PropDocs Workspace</p>
                  <h2 className="text-2xl font-semibold text-gray-900">Welcome, Alex 👋</h2>
                </div>
                <div className="ml-auto">
                  <Button variant="outline" size="sm">
                    Your account
                  </Button>
                </div>
              </div>

              {/* Hero Section with Home Details */}
              <Card className="bg-gradient-to-r from-blue-50 to-indigo-50 border-0">
                <CardContent className="p-8">
                  <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Main Content */}
                    <div className="lg:col-span-2">
                      <h3 className="text-2xl font-semibold text-gray-900 mb-2">
                        Your home's complete maintenance history
                      </h3>
                      <p className="text-gray-600 mb-6">
                        Track every system, schedule maintenance, and maintain your property value with intelligent
                        automation and expert contractor connections.
                      </p>
                      <div className="flex flex-wrap gap-3 mb-8">
                        <Button>
                          <Plus className="w-4 h-4 mr-2" />
                          Add an asset
                        </Button>
                        <Button variant="outline">
                          <Search className="w-4 h-4 mr-2" />
                          Find contractors
                        </Button>
                      </div>

                      {/* Home Details */}
                      <div className="bg-white/80 backdrop-blur-sm rounded-lg p-6 border border-white/50">
                        <div className="flex items-center justify-between mb-4">
                          <h4 className="font-semibold text-gray-900 flex items-center">
                            <MapPin className="w-4 h-4 mr-2" />
                            Your Property Details
                          </h4>
                          <Button variant="ghost" size="sm" className="text-blue-600">
                            Edit Details
                          </Button>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                          <div>
                            <p className="text-gray-600">Address</p>
                            <p className="font-medium text-gray-900">{homeDetails.address}</p>
                          </div>
                          <div>
                            <p className="text-gray-600">Year Built</p>
                            <p className="font-medium text-gray-900">{homeDetails.yearBuilt}</p>
                          </div>
                          <div>
                            <p className="text-gray-600">Square Footage</p>
                            <p className="font-medium text-gray-900">
                              {homeDetails.squareFootage.toLocaleString()} sq ft
                            </p>
                          </div>
                          <div>
                            <p className="text-gray-600">Bedrooms / Bathrooms</p>
                            <p className="font-medium text-gray-900">
                              {homeDetails.bedrooms} bed / {homeDetails.bathrooms} bath
                            </p>
                          </div>
                          <div>
                            <p className="text-gray-600">Property Value</p>
                            <p className="font-medium text-gray-900">{homeDetails.propertyValue}</p>
                          </div>
                          <div>
                            <p className="text-gray-600">Last Appraisal</p>
                            <p className="font-medium text-gray-900">{homeDetails.lastAppraisal}</p>
                          </div>
                        </div>

                        <div className="mt-4 pt-4 border-t border-gray-200">
                          <div className="grid grid-cols-3 gap-4 text-center">
                            <div>
                              <p className="text-2xl font-bold text-blue-600">{homeDetails.maintenanceScore}%</p>
                              <p className="text-xs text-gray-600">Maintenance Score</p>
                            </div>
                            <div>
                              <p className="text-2xl font-bold text-gray-900">{homeDetails.totalAssets}</p>
                              <p className="text-xs text-gray-600">Total Assets</p>
                            </div>
                            <div>
                              <p className="text-2xl font-bold text-orange-600">{homeDetails.upcomingTasks}</p>
                              <p className="text-xs text-gray-600">Upcoming Tasks</p>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Dashboard Preview */}
                    <div className="hidden lg:block">
                      <div className="w-full h-full bg-white rounded-lg shadow-sm border border-gray-200 relative overflow-hidden">
                        {/* Modern Home Image - Enlarged and Cropped */}
                        <div className="relative h-full rounded-lg overflow-hidden">
                          <img
                            src="/images/modern-home.png"
                            alt="Modern home with wood siding and large windows"
                            className="w-full h-full object-cover object-center scale-150"
                            style={{ transformOrigin: "center center" }}
                          />

                          {/* Overlay gradient for better text visibility */}
                          <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent"></div>

                          {/* Floating maintenance icons */}
                          <div className="absolute top-6 left-6 w-10 h-10 bg-blue-500/90 backdrop-blur-sm rounded-full flex items-center justify-center animate-bounce shadow-lg">
                            <Wind className="w-5 h-5 text-white" />
                          </div>
                          <div
                            className="absolute top-16 right-8 w-10 h-10 bg-green-500/90 backdrop-blur-sm rounded-full flex items-center justify-center animate-bounce shadow-lg"
                            style={{ animationDelay: "0.5s" }}
                          >
                            <Droplets className="w-5 h-5 text-white" />
                          </div>
                          <div
                            className="absolute bottom-12 left-10 w-10 h-10 bg-yellow-500/90 backdrop-blur-sm rounded-full flex items-center justify-center animate-bounce shadow-lg"
                            style={{ animationDelay: "1s" }}
                          >
                            <Zap className="w-5 h-5 text-white" />
                          </div>

                          {/* Status indicators */}
                          <div className="absolute top-6 right-6 flex flex-col space-y-2">
                            <div className="w-4 h-4 bg-green-400 rounded-full animate-pulse shadow-sm"></div>
                            <div
                              className="w-4 h-4 bg-blue-400 rounded-full animate-pulse shadow-sm"
                              style={{ animationDelay: "0.3s" }}
                            ></div>
                            <div
                              className="w-4 h-4 bg-yellow-400 rounded-full animate-pulse shadow-sm"
                              style={{ animationDelay: "0.6s" }}
                            ></div>
                          </div>

                          {/* Bottom overlay text */}
                          <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-6">
                            <div className="text-white text-base font-semibold">Complete Home Management</div>
                            <div className="text-white/90 text-sm mt-1">
                              Track every system, maintain property value
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Action Items */}
                <div className="lg:col-span-2">
                  <Card>
                    <CardHeader className="pb-4">
                      <div className="flex items-center justify-between">
                        <CardTitle className="text-lg font-semibold">Your action items</CardTitle>
                        <Badge
                          variant="destructive"
                          className="rounded-full w-6 h-6 p-0 flex items-center justify-center text-xs"
                        >
                          1
                        </Badge>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="flex items-center justify-between">
                        <h4 className="font-medium text-gray-900">Finish setting up your account</h4>
                        <span className="text-sm text-gray-500">1</span>
                      </div>

                      <div className="space-y-3">
                        {actionItems.map((item) => (
                          <div key={item.id} className="flex items-center space-x-3">
                            {item.completed ? (
                              <CheckCircle className="w-5 h-5 text-green-500" />
                            ) : (
                              <Circle className="w-5 h-5 text-gray-300" />
                            )}
                            <span
                              className={`text-sm ${item.completed ? "text-gray-500 line-through" : "text-gray-900"}`}
                            >
                              {item.text}
                            </span>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  </Card>

                  {/* Quick Stats */}
                  <div className="grid grid-cols-2 gap-4 mt-6">
                    <Card>
                      <CardContent className="p-6">
                        <div className="flex items-center justify-between">
                          <div>
                            <p className="text-3xl font-bold text-gray-900">3</p>
                            <p className="text-sm text-gray-600">Active assets</p>
                          </div>
                          <ExternalLink className="w-4 h-4 text-gray-400" />
                        </div>
                      </CardContent>
                    </Card>

                    <Card>
                      <CardContent className="p-6">
                        <h3 className="font-medium text-gray-900 mb-4">Schedule your next maintenance</h3>
                        <Button variant="outline" size="sm" className="w-full bg-transparent">
                          <Plus className="w-4 h-4 mr-2" />
                          Schedule maintenance
                        </Button>
                      </CardContent>
                    </Card>
                  </div>
                </div>

                {/* Sidebar Cards */}
                <div className="space-y-6">
                  <Card>
                    <CardHeader className="pb-4">
                      <div className="flex items-center justify-between">
                        <CardTitle className="text-lg font-semibold">January maintenance spend</CardTitle>
                        <ExternalLink className="w-4 h-4 text-gray-400" />
                      </div>
                    </CardHeader>
                    <CardContent>
                      <p className="text-3xl font-bold text-gray-900 mb-2">$0</p>
                      <Button variant="outline" size="sm">
                        <Activity className="w-4 h-4 mr-2" />
                        View Insights
                      </Button>
                    </CardContent>
                  </Card>

                  <Card>
                    <CardContent className="p-6">
                      <h3 className="font-medium text-gray-900 mb-2">Bring your team to PropDocs</h3>
                      <p className="text-sm text-gray-600 mb-4">
                        Invite your family members and current contractor network
                      </p>
                      <div className="space-y-2">
                        <Button variant="outline" size="sm" className="w-full justify-start bg-transparent">
                          <Users className="w-4 h-4 mr-2" />
                          Invite family
                        </Button>
                        <Button variant="outline" size="sm" className="w-full justify-start bg-transparent">
                          <Wrench className="w-4 h-4 mr-2" />
                          Add contractor
                        </Button>
                      </div>
                    </CardContent>
                  </Card>

                  <div className="flex items-center space-x-2">
                    <div className="flex -space-x-2">
                      <Avatar className="w-8 h-8 border-2 border-white">
                        <AvatarFallback className="bg-blue-500 text-white text-xs">JD</AvatarFallback>
                      </Avatar>
                      <Avatar className="w-8 h-8 border-2 border-white">
                        <AvatarFallback className="bg-green-500 text-white text-xs">SM</AvatarFallback>
                      </Avatar>
                      <Avatar className="w-8 h-8 border-2 border-white">
                        <AvatarFallback className="bg-purple-500 text-white text-xs">AL</AvatarFallback>
                      </Avatar>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeView === "assets" && (
            <div className="max-w-6xl mx-auto">
              <div className="mb-6">
                <h1 className="text-2xl font-semibold text-gray-900 mb-2">Your Property Assets</h1>
                <p className="text-gray-600">Track and manage all your property systems in one place</p>
              </div>

              <Card>
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <CardTitle>Asset Overview</CardTitle>
                    <Button>
                      <Plus className="w-4 h-4 mr-2" />
                      Add Asset
                    </Button>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {assets.map((asset) => {
                      const IconComponent = asset.icon
                      const isExpanded = selectedAsset === asset.id

                      return (
                        <div key={asset.id} className="border border-gray-200 rounded-lg">
                          {/* Asset Summary */}
                          <div
                            className="flex items-center justify-between p-4 cursor-pointer hover:bg-gray-50 transition-colors"
                            onClick={() => setSelectedAsset(isExpanded ? null : asset.id)}
                          >
                            <div className="flex items-center space-x-4">
                              <div className="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                                <IconComponent className="w-5 h-5 text-gray-600" />
                              </div>
                              <div>
                                <h3 className="font-medium text-gray-900">{asset.name}</h3>
                                <p className="text-sm text-gray-600">{asset.category}</p>
                              </div>
                            </div>
                            <div className="flex items-center space-x-4">
                              <Badge
                                variant={
                                  asset.status === "Excellent"
                                    ? "default"
                                    : asset.status === "Needs Attention"
                                      ? "destructive"
                                      : "secondary"
                                }
                                className={
                                  asset.status === "Excellent"
                                    ? "bg-green-100 text-green-700 border-green-200"
                                    : asset.status === "Needs Attention"
                                      ? "bg-red-100 text-red-700 border-red-200"
                                      : "bg-yellow-100 text-yellow-700 border-yellow-200"
                                }
                              >
                                {asset.status}
                              </Badge>
                              <span className="text-sm text-gray-600">{asset.nextMaintenance}</span>
                              {isExpanded ? (
                                <ChevronDown className="w-4 h-4 text-gray-400" />
                              ) : (
                                <ChevronRight className="w-4 h-4 text-gray-400" />
                              )}
                            </div>
                          </div>

                          {/* Expanded Asset Details */}
                          {isExpanded && (
                            <div className="border-t border-gray-200 p-6 bg-gray-50">
                              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                                {/* Asset Information */}
                                <div className="lg:col-span-2 space-y-6">
                                  <div>
                                    <h4 className="font-semibold text-gray-900 mb-4">Asset Information</h4>
                                    <div className="grid grid-cols-2 gap-4 text-sm">
                                      <div>
                                        <p className="text-gray-600">Model</p>
                                        <p className="font-medium text-gray-900">{asset.model}</p>
                                      </div>
                                      <div>
                                        <p className="text-gray-600">Install Date</p>
                                        <p className="font-medium text-gray-900">{asset.installDate}</p>
                                      </div>
                                      <div>
                                        <p className="text-gray-600">Asset Value</p>
                                        <p className="font-medium text-gray-900">{asset.value}</p>
                                      </div>
                                      <div>
                                        <p className="text-gray-600">Efficiency</p>
                                        <div className="flex items-center space-x-2">
                                          <Progress value={asset.efficiency} className="h-2 flex-1" />
                                          <span className="font-medium text-gray-900">{asset.efficiency}%</span>
                                        </div>
                                      </div>
                                      <div>
                                        <p className="text-gray-600">Warranty</p>
                                        <p className="font-medium text-gray-900">{asset.warranty}</p>
                                      </div>
                                      <div>
                                        <p className="text-gray-600">Last Service</p>
                                        <p className="font-medium text-gray-900">{asset.lastService}</p>
                                      </div>
                                      <div className="col-span-2">
                                        <p className="text-gray-600">Preferred Contractor</p>
                                        <p className="font-medium text-gray-900">{asset.contractor}</p>
                                      </div>
                                    </div>
                                  </div>

                                  <div>
                                    <h4 className="font-semibold text-gray-900 mb-3">Notes</h4>
                                    <p className="text-sm text-gray-700 bg-white p-3 rounded border">{asset.notes}</p>
                                  </div>

                                  <div>
                                    <h4 className="font-semibold text-gray-900 mb-4">Maintenance History</h4>
                                    <div className="space-y-3">
                                      {asset.maintenanceHistory.map((record, index) => (
                                        <div
                                          key={index}
                                          className="flex items-center justify-between p-3 bg-white rounded border"
                                        >
                                          <div>
                                            <p className="font-medium text-gray-900">{record.service}</p>
                                            <p className="text-sm text-gray-600">
                                              {record.contractor} • {record.date}
                                            </p>
                                          </div>
                                          <span className="font-medium text-gray-900">{record.cost}</span>
                                        </div>
                                      ))}
                                    </div>
                                  </div>
                                </div>

                                {/* Actions Panel */}
                                <div className="space-y-4">
                                  <div className="bg-white p-4 rounded-lg border">
                                    <h4 className="font-semibold text-gray-900 mb-4">Quick Actions</h4>
                                    <div className="space-y-3">
                                      <Button
                                        className="w-full justify-start"
                                        onClick={() => handleScheduleMaintenance(asset.id)}
                                      >
                                        <Calendar className="w-4 h-4 mr-2" />
                                        Schedule Maintenance
                                      </Button>
                                      <Button variant="outline" className="w-full justify-start bg-transparent">
                                        <Phone className="w-4 h-4 mr-2" />
                                        Contact Contractor
                                      </Button>
                                      <Button variant="outline" className="w-full justify-start bg-transparent">
                                        <FileText className="w-4 h-4 mr-2" />
                                        View Documents
                                      </Button>
                                      <Button variant="outline" className="w-full justify-start bg-transparent">
                                        <Settings className="w-4 h-4 mr-2" />
                                        Edit Asset
                                      </Button>
                                    </div>
                                  </div>

                                  {/* Status Alert */}
                                  {asset.status === "Needs Attention" && (
                                    <div className="bg-red-50 border border-red-200 p-4 rounded-lg">
                                      <div className="flex items-start space-x-2">
                                        <AlertTriangle className="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
                                        <div>
                                          <h5 className="font-medium text-red-900">Attention Required</h5>
                                          <p className="text-sm text-red-700 mt-1">
                                            This asset needs immediate attention. Schedule maintenance soon.
                                          </p>
                                        </div>
                                      </div>
                                    </div>
                                  )}

                                  {/* Next Maintenance */}
                                  <div className="bg-blue-50 border border-blue-200 p-4 rounded-lg">
                                    <div className="flex items-start space-x-2">
                                      <Clock className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" />
                                      <div>
                                        <h5 className="font-medium text-blue-900">Next Maintenance</h5>
                                        <p className="text-sm text-blue-700 mt-1">
                                          Scheduled for {asset.nextMaintenance}
                                        </p>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                          )}
                        </div>
                      )
                    })}
                  </div>
                </CardContent>
              </Card>
            </div>
          )}

          {activeView === "maintenance" && (
            <div className="max-w-4xl mx-auto">
              <div className="mb-6">
                <h1 className="text-2xl font-semibold text-gray-900 mb-2">Maintenance Schedule</h1>
                <p className="text-gray-600">Stay on top of your property maintenance tasks</p>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Upcoming Tasks</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-gray-900">HVAC Filter Replacement</h4>
                        <Badge variant="destructive">High Priority</Badge>
                      </div>
                      <p className="text-sm text-gray-600 mb-3">Due: January 28, 2024</p>
                      <Button size="sm">Schedule Now</Button>
                    </div>
                    <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-gray-900">Water Heater Inspection</h4>
                        <Badge variant="secondary">Medium Priority</Badge>
                      </div>
                      <p className="text-sm text-gray-600 mb-3">Due: January 30, 2024</p>
                      <Button size="sm" variant="outline">
                        Find Contractor
                      </Button>
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle>Maintenance Calendar</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-7 gap-1 text-center text-sm mb-4">
                      {["S", "M", "T", "W", "T", "F", "S"].map((day) => (
                        <div key={day} className="p-2 font-medium text-gray-600">
                          {day}
                        </div>
                      ))}
                      {Array.from({ length: 35 }, (_, i) => (
                        <div
                          key={i}
                          className={`p-2 text-sm hover:bg-gray-100 rounded cursor-pointer transition-colors ${
                            i === 15 || i === 22 ? "bg-red-100 text-red-700 font-medium" : "text-gray-700"
                          }`}
                        >
                          {i + 1 <= 31 ? i + 1 : ""}
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>
          )}

          {activeView === "contractors" && (
            <div className="max-w-4xl mx-auto">
              <div className="mb-6">
                <h1 className="text-2xl font-semibold text-gray-900 mb-2">Contractor Network</h1>
                <p className="text-gray-600">Connect with verified professionals in your area</p>
              </div>

              <Card>
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <CardTitle>Available Contractors</CardTitle>
                    <Button variant="outline">
                      <Filter className="w-4 h-4 mr-2" />
                      Filter
                    </Button>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {[
                      {
                        name: "Mike's HVAC Services",
                        rating: 4.8,
                        specialty: "HVAC & Heating",
                        distance: "2.3 miles",
                        available: true,
                      },
                      {
                        name: "PlumbPro Solutions",
                        rating: 4.9,
                        specialty: "Plumbing & Water Systems",
                        distance: "1.8 miles",
                        available: true,
                      },
                      {
                        name: "ElectricMax",
                        rating: 4.7,
                        specialty: "Electrical & Wiring",
                        distance: "3.1 miles",
                        available: false,
                      },
                    ].map((contractor, index) => (
                      <div
                        key={index}
                        className="flex items-center justify-between p-4 border border-gray-200 rounded-lg"
                      >
                        <div className="flex items-center space-x-4">
                          <Avatar className="w-10 h-10">
                            <AvatarFallback className="bg-gray-100 text-gray-600 font-medium">
                              {contractor.name
                                .split(" ")
                                .map((n) => n[0])
                                .join("")}
                            </AvatarFallback>
                          </Avatar>
                          <div>
                            <h3 className="font-medium text-gray-900">{contractor.name}</h3>
                            <p className="text-sm text-gray-600">{contractor.specialty}</p>
                            <div className="flex items-center space-x-4 mt-1">
                              <div className="flex items-center space-x-1">
                                <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                                <span className="text-sm font-medium">{contractor.rating}</span>
                              </div>
                              <span className="text-sm text-gray-600">{contractor.distance}</span>
                            </div>
                          </div>
                        </div>
                        <div className="flex items-center space-x-3">
                          <Badge variant={contractor.available ? "default" : "secondary"}>
                            {contractor.available ? "Available" : "Busy"}
                          </Badge>
                          <Button size="sm" disabled={!contractor.available}>
                            <Phone className="w-4 h-4 mr-2" />
                            Contact
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          )}
        </main>
      </div>

      {/* Schedule Maintenance Modal */}
      <ScheduleModal />
    </div>
  )
}
