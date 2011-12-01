var express = require('express');
var app = require('express').createServer();

app.listen(3000);

app.get('/api/contact', function(request, response){
	response.json([{email:'anthony.alesia@vokalinteractive.com',name:'Anthony Alesia',imageUrl:'http://www.gravatar.com/avatar/73334cf54111e4551cc24192e4b24efe.png'},
{email:'reid.lappin@vokalinteractive.com',name:'Reid Lappin',imageUrl:'http://www.gravatar.com/avatar/3bf94c773ab383efe527ceba1b4c621f.png'},
{email: 'brandon.passley@vokalinteractive.com',name:'Brandon Passley',imageUrl:'http://www.gravatar.com/avatar/bfb2194d66c5aed23a2c09b8b71ec515.png'},
{email:'nick.ross@vokalinteractive.com',name:'Nick Ross',imageUrl:'http://www.gravatar.com/avatar/75930a49761b6bca59ef76edeb7eccb9.png'},
{email:'scott.ferguson@vokalinteractive.com',name:'Scott Ferguson',imageUrl:'http://www.gravatar.com/avatar/3f52e509f45eb3ff0d9707321c57937d.png'},
{email:'bill.best@vokalinteractive.com',name:'Bill Best',imageUrl:'http://www.gravatar.com/avatar/47752a1b1736de61b3b5e7c71b3ad7fc.png'},
{email:'scott.ferguson@vokalinteractive.com',name:'Scott Ferguson',imageUrl:'http://www.gravatar.com/avatar/3f52e509f45eb3ff0d9707321c57937d.png'},
{email: 'john.forester@vokalinteractive.com',name:'John Forester',imageUrl:'http://www.gravatar.com/avatar/5841e6a4b0e6bbd9cbf34eb5dfd4fe29.png'},
{email:'joe.call@vokalinteractive.com',name:'Joe Call',imageUrl:'http://www.gravatar.com/avatar/a194d234d474c9c4758974d6be8faffc.png'},
{email:'andy.mack@vokalinteractive.com',name: 'Andy Mack',imageUrl:'http://www.gravatar.com/avatar/a91e2a2c16568e885b46fbe8f5d28bc6.png'}]
	    );
});