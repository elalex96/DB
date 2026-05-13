USE [Petrovendor]
GO
DROP PROC IF EXISTS USP_SEL_TA_ConsultarAprobadoresComprobanteExtranjeroMercadeo
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 28-01-2026
-- Description:	Issue #3250 Consultar aprobadores comprobante extranjero
-- =============================================
CREATE  PROCEDURE [dbo].[USP_SEL_TA_ConsultarAprobadoresComprobanteExtranjeroMercadeo]  
@IdOperacion int,
@IdProveedor INT,
@IdUsuario INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT TT.IdAprobador, 
	TT.NoSecuencia, 
	U.Nombre as Aprobadores, 
	TT.IdEstatus, 
	TE.Nombre AS NombreEstatus, 
	ISNULL(TT.Comentario,'') AS Comentario, 
	ISNULL(FORMAT(TT.FechaCambioEstatus, 'dd/MM/yyyy hh:mm tt'),'') AS FechaCambioEstatus, 
	TT.IdTarea, 
	TT.IdOperacion, 
	CASE WHEN UA.Nombre IS NULL THEN 
		'Asignado por el flujo predeterminado'
	ELSE 
	CONCAT(UA.Nombre, 
			' el día ', ISNULL(FORMAT(TT.FechaRegistro,'dd/MM/yyyy hh:mm tt'),''),
			(CASE WHEN LEN(ISNULL(TT.MensajeAsignacion,''))>0 THEN ', Mensaje:'+ISNULL(TT.MensajeAsignacion,'') ELSE '' END)	
	)
	END  AS Asignador, 
	TAO.IdEstatusOperacion  AS EstatusFactura	
	FROM TA_Tarea TT (NOLOCK)
	JOIN TA_Operacion TAO  (NOLOCK)
		ON TT.IdOperacion = TAO.IdOperacion
		AND TAO.IdTipoOperacion = 16 ---> CTE Ta_TipoOperacion -->  Aprobación Pedimento/Comprobante Extranjero
	JOIN S_Usuario U (NOLOCK)
		ON TT.IdAprobador	= U.IdUsuario 		
	LEFT JOIN TA_Estatus TE (NOLOCK) 
		ON TT.IdEstatus = TE.IdEstatus 
	LEFT JOIN dbo.S_Usuario UA  (NOLOCK)
		ON TT.AsignadoPor= UA.IdUsuario
	WHERE  TT.IdOperacion= @IdOperacion
	 AND TT.Activo = 1
	ORDER BY TT.NoSecuencia ASC

END

 