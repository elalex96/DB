CREATE PROCEDURE [dbo].[Mobile_NotificacionesEntregables]
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
    --SELECT DISTINCT(IdContratoEntregable) INTO #ContratosEntregable FROM dbo.EN_InstanciasEntregable WHERE FechasLimiteElaboracion = '2020-07-14'
	SELECT DISTINCT(IdContratoEntregable) INTO #ContratosEntregable FROM dbo.EN_InstanciasEntregable WHERE FechasLimiteElaboracion = GETDATE()
	
	SELECT UsuarioAprueba,IdEntregable INTO #CE FROM dbo.EN_ContratoEntregable WHERE IdContratoEntregable IN (SELECT * FROM #ContratosEntregable)

	
	INSERT INTO dbo.AM_OneSignalNotificaciones
	(
    Para,
    Player,
    TItulo,
    Subtitulo,
    Mensaje,
    FechaCreacion,
    FechaModificacion,
    Enviado,
    Enviar,
	IdTareaOrigen
	)
	SELECT 
		OSP.Usuario AS Para
		,OSP.PlayerId AS Player
		,'ELABORACIÓN DE ENTREGABLE' AS Titulo
		,CONCAT('En. Pendiente ',CE.IdEntregable) AS Subtitulo
		,CONCAT('Tiene un entregable pendente por elaborar para el regulador ', RE.Regulador) AS Mensaje
		,GETDATE() AS FechaCreacion
		,NULL AS FechaModificacion
		,0 AS Enviado
		,1 AS Enviar 
		,CE.IdEntregable
	FROM dbo.AP_Usuario AS Ap
	JOIN #CE AS CE 
	ON CE.UsuarioAprueba = Ap.UsuarioID
	JOIN dbo.EN_Entregable AS EN
	ON EN.IdEntregable = CE.IdEntregable
	JOIN dbo.AM_OneSignalPlayers AS OSP
	ON OSP.Usuario = Ap.Usuario
	JOIN CO_Regulador AS RE 
	ON RE.IdRegulador = EN.IdRegulador

