fx_version 'cerulean'
game 'gta5'

description 'QB-VehicleSales'
version '1.0.0'

ui_page 'html/ui.html'

shared_scripts { 
	'@qb-core/import.lua',
	'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
	'html/reset.css',
	'html/new-sell-contract.png',
	'html/new-buy-contract.png',
	'html/ui.css',
	'html/ui.html',
	'html/ui.js',
}
