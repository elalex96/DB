CREATE PROCEDURE [dbo].[Mobile_EntregableDetalle]
    @IdEntregable AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
    SELECT 
		TOP 1
		REG.LogoRegulador
		,EN.DocumentoEntregable
		,INS.FechasLimiteElaboracion
		,INS.FechasLimiteRevision
		,INS.FechasLimiteAprobacion
		,US.Nombre
		,USU.Nombre
		,USUA.Nombre
		,EN.Consecutivo
		,MAR.MarcoLegal
		,EN.TituloAnexo
		,EN.Capitulo
		,CONEN.AreaResponsable
		FROM 
	dbo.CO_Regulador AS REG
	JOIN dbo.EN_Entregable EN
	ON EN.IdRegulador = REG.IdRegulador
	JOIN dbo.EN_ContratoEntregable AS CONEN
	ON CONEN.IdEntregable = EN.IdEntregable
	JOIN dbo.EN_InstanciasEntregable AS INS
	ON INS.IdContratoEntregable = CONEN.IdContratoEntregable
	JOIN dbo.AP_Usuario AS US
	ON US.UsuarioID = CONEN.UsuarioElabora
	JOIN dbo.AP_Usuario AS USU
	ON USU.UsuarioID = CONEN.UsuarioRevision
	JOIN dbo.AP_Usuario AS USUA
	ON USUA.UsuarioID = CONEN.UsuarioAprueba
	JOIN dbo.EN_MarcoLegal AS MAR
	ON MAR.IdMarcoLegal = EN.IdMarcoLegal
	WHERE EN.IdEntregable =@IdEntregable
