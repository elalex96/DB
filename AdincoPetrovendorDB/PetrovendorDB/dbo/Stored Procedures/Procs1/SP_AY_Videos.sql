create procedure [dbo].[SP_AY_Videos](@idVideo int)
as
begin
select UrlVideo from AY_Videos where idVideo=@idVideo
end
