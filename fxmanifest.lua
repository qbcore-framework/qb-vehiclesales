fx_version 'cerulean'
game 'gta5'

description 'QB-VehicleSales'
version '1.0.0'

ui_page "html/ui.html"

client_scripts {
	'client/main.lua',
	'config.lua',
}

server_scripts {
	'server/main.lua',
	'config.lua',
}

files {
	'html/reset.css',
	'html/new-sell-contract.png',
	'html/new-buy-contract.png',
	'html/ui.css',
	'html/ui.html',
	'html/ui.js',
}
