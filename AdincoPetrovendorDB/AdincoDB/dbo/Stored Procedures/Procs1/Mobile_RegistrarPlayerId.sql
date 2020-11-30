CREATE PROCEDURE [dbo].[Mobile_RegistrarPlayerId]
@PlayerId NVARCHAR(100),
@CorreoUsuario NVARCHAR(80),
@Dispositivo NVARCHAR(80)
AS
BEGIN
DECLARE @Cont int;
	
	--SELECT
	--	ROW_NUMBER() OVER(ORDER BY IdDevice ASC) AS Row#, 
	--	PlayerId 
	--	FROM dbo.AM_OneSignalPlayers 	
	SELECT @Cont = COUNT(*) FROM dbo.AM_OneSignalPlayers WHERE PlayerId = @PlayerId

IF	@Cont=0
	BEGIN
		INSERT INTO dbo.AM_OneSignalPlayers(PlayerId,Usuario,CreadoEl,IsActivo,Dispositivo) VALUES(@PlayerId,@CorreoUsuario,GETDATE(),1,@Dispositivo)
	END 
END 
IF @Cont > 0
BEGIN
	UPDATE dbo.AM_OneSignalPlayers
	SET Usuario = @CorreoUsuario,
	IsActivo = 1,
	Dispositivo = @Dispositivo
	WHERE PlayerId = @PlayerId
END

