-- =============================================
-- Author: Daniel AC
-- Create date: 02/09/2019
-- Description:	Consultar aprobadores de factura
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_ConsultarAprobadoresFactura]  
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
			(CASE WHEN LEN(ISNULL(TT.MensajeAsignacion,''))>0 THEN ' Mensaje:'+TT.MensajeAsignacion ELSE '' END)	
	)
	END  AS Asignador, 
	TAO.IdEstatusOperacion  AS EstatusFactura	
	FROM TA_Tarea TT 	
	JOIN TA_Operacion TAO 
		ON TT.IdOperacion = TAO.IdOperacion
		AND TAO.IdTipoOperacion = 10 ---> CTE APROBACIÓN DE FACTURA
	JOIN S_Usuario U	
		ON TT.IdAprobador	= U.IdUsuario 		
	LEFT JOIN TA_Estatus TE 
		ON TT.IdEstatus = TE.IdEstatus 
	LEFT JOIN dbo.S_Usuario UA 
		ON TT.AsignadoPor= UA.IdUsuario
	WHERE  TT.IdOperacion= @IdOperacion
	 AND TT.Activo=1
	ORDER BY TT.NoSecuencia ASC

END

 