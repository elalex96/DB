USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_ENT_ActividadesUsuarioContrato'
)
    DROP PROCEDURE USP_SEL_ENT_ActividadesUsuarioContrato;
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/10/2024>
-- Description:	<Consulta de los entregables que tienen actividades ligadas al usuario>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_ENT_ActividadesUsuarioContrato] --3,1
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	CREATE TABLE #ENTREGABLES_USUARIO(
		IdContratoEntregable INT,
		Consecutivo NVARCHAR(100),
		DocumentoEntregable NVARCHAR(1000),
		Area NVARCHAR(1000),
		NombreEstado NVARCHAR(1000),
		Activo bit
	);

	DECLARE @CorreoUsuarioSeleccionado NVARCHAR(100) = (SELECT Usuario FROM AP_Usuario WHERE UsuarioID = @IdUsuario);

    -- Insert statements for procedure here
	INSERT INTO #ENTREGABLES_USUARIO
	SELECT 
		CE.IdContratoEntregable,
		ISNULL(EN.Consecutivo, '') Consecutivo,
		EN.DocumentoEntregable,
		AR.NombreArea,
		(SELECT STUFF(
			(SELECT ', ' + ES.NombreEstado
			FROM EN_Estado AS ES
				JOIN EN_Actividad AS ACI (NOLOCK) 
					ON ES.EstadoID = ACI.EstadoID
					AND ACI.IdContratoEntregable = CE.IdContratoEntregable
					AND ES.NombreEstado <> 'Aprobado Internamente'
					AND ACI.idUsuario = @IdUsuario
			FOR XML PATH ('')),
		1,2, '')) AS NombreEstado,
		CE.Activo
	FROM EN_Entregable EN (NOLOCK)
		JOIN EN_ContratoEntregable CE (NOLOCK)
			ON CE.IdContrato = @IdContrato
			AND EN.IdEntregable = CE.IdEntregable
		JOIN EN_Actividad AS AC (NOLOCK)
			ON CE.IdContratoEntregable = AC.IdContratoEntregable
			AND AC.idUsuario = @IdUsuario
		JOIN EN_Area AS AR (NOLOCK)
			ON CE.IdArea = AR.idArea
	GROUP BY CE.IdContratoEntregable,
		ISNULL(EN.Consecutivo, ''),
		EN.DocumentoEntregable,
		AR.NombreArea,
		CE.Activo;

	--SE BUSCAN LOS USUARIO FOCAL POINT
	INSERT INTO #ENTREGABLES_USUARIO
	SELECT 
		CE.IdContratoEntregable,
		ISNULL(EN.Consecutivo, '') Consecutivo,
		EN.DocumentoEntregable,
		AR.NombreArea,
		'Focal Point' AS NombreEstado,
		CE.Activo
	FROM EN_Entregable EN (NOLOCK)
		JOIN EN_ContratoEntregable CE (NOLOCK)
			ON CE.IdContrato = @IdContrato
			AND EN.IdEntregable = CE.IdEntregable
		JOIN EN_Area AS AR (NOLOCK)
			ON CE.IdArea = AR.idArea
	WHERE CE.FocalPoint LIKE '%' + @CorreoUsuarioSeleccionado + '%'
	GROUP BY CE.IdContratoEntregable,
		ISNULL(EN.Consecutivo, ''),
		EN.DocumentoEntregable,
		AR.NombreArea,
		CE.Activo;

	--SE BUSCAN LOS USUARIO ACCOUNTABLE
	INSERT INTO #ENTREGABLES_USUARIO
	SELECT 
		CE.IdContratoEntregable,
		ISNULL(EN.Consecutivo, '') Consecutivo,
		EN.DocumentoEntregable,
		AR.NombreArea,
		'Accountable' AS NombreEstado,
		CE.Activo
	FROM EN_Entregable EN (NOLOCK)
		JOIN EN_ContratoEntregable CE (NOLOCK)
			ON CE.IdContrato = @IdContrato
			AND EN.IdEntregable = CE.IdEntregable
		JOIN EN_Area AS AR (NOLOCK)
			ON CE.IdArea = AR.idArea
	WHERE CE.Accountable LIKE '%' + @CorreoUsuarioSeleccionado + '%'
	GROUP BY CE.IdContratoEntregable,
		ISNULL(EN.Consecutivo, ''),
		EN.DocumentoEntregable,
		AR.NombreArea,
		CE.Activo;

	--SE BUSCAN LOS USUARIO ACCOUNTABLE COMPLIANCE
	INSERT INTO #ENTREGABLES_USUARIO
	SELECT 
		CE.IdContratoEntregable,
		ISNULL(EN.Consecutivo, '') Consecutivo,
		EN.DocumentoEntregable,
		AR.NombreArea,
		'Accountable Compliance' AS NombreEstado,
		CE.Activo
	FROM EN_Entregable EN (NOLOCK)
		JOIN EN_ContratoEntregable CE (NOLOCK)
			ON CE.IdContrato = @IdContrato
			AND EN.IdEntregable = CE.IdEntregable
		JOIN EN_Area AS AR (NOLOCK)
			ON CE.IdArea = AR.idArea
	WHERE CE.AccountableCompliance LIKE '%' + @CorreoUsuarioSeleccionado + '%'
	GROUP BY CE.IdContratoEntregable,
		ISNULL(EN.Consecutivo, ''),
		EN.DocumentoEntregable,
		AR.NombreArea,
		CE.Activo;


	SELECT
		EUS.IdContratoEntregable,
		EUS.Consecutivo,
		EUS.DocumentoEntregable,
		EUS.Area,
		(SELECT STUFF(
			(SELECT ', ' + ES.NombreEstado
			FROM #ENTREGABLES_USUARIO AS ES
			WHERE ES.IdContratoEntregable = EUS.IdContratoEntregable
			FOR XML PATH ('')),
		1,2, '')) AS Estado,
		(SELECT COUNT(idInstanciaEntregable) FROM EN_InstanciasEntregable WHERE IdContratoEntregable = EUS.IdContratoEntregable) AS Programaciones,
		EUS.Activo
	FROM #ENTREGABLES_USUARIO AS EUS
	GROUP BY EUS.IdContratoEntregable,
		EUS.Consecutivo,
		EUS.DocumentoEntregable,
		EUS.Area,
		EUS.Activo;
	
END
