-- =============================================
-- Author: Daniel AC
-- Create date: 02/09/2019
-- Description:	Consultar aprobadores de nota de crédito
-- =============================================
CREATE  PROCEDURE [dbo].[SP_ConsultarAprobadoresNotaCredito]  
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
	INNER JOIN TA_Operacion TAO ON TT.IdOperacion = TAO.IdOperacion
	LEFT JOIN S_Usuario U	ON U.IdUsuario = TT.IdAprobador	
	LEFT JOIN TA_Estatus TE ON TE.IdEstatus = TT.IdEstatus	
	LEFT JOIN dbo.S_Usuario UA ON TT.AsignadoPor= UA.IdUsuario
	WHERE   TAO.IdTipoOperacion = 17 ---> APROBACIÓN DE NOTA DE CREDITO
	 AND TT.IdOperacion= @IdOperacion
	 AND TT.Activo=1
	ORDER BY TT.NoSecuencia ASC

	--- TT.IdEstatus = 2
END
