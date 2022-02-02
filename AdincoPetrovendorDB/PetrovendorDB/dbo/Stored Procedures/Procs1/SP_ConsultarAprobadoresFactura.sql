USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ConsultarAprobadoresFactura]    Script Date: 02/02/2022 12:11:29 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 02/09/2019
-- Description:	Consultar aprobadores de factura
-- =============================================
ALTER  PROCEDURE [dbo].[SP_ConsultarAprobadoresFactura]  
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
	LEFT JOIN S_Usuario U	ON U.IdUsuario = TT.IdAprobador	AND U.Activo = 1
	LEFT JOIN TA_Estatus TE ON TE.IdEstatus = TT.IdEstatus	
	LEFT JOIN dbo.S_Usuario UA ON TT.AsignadoPor= UA.IdUsuario
	WHERE   TAO.IdTipoOperacion = 10 ---> APROBACIÓN DE FACTURA
	 AND TT.IdOperacion= @IdOperacion
	 AND TT.Activo=1
	ORDER BY TT.NoSecuencia ASC

	--- TT.IdEstatus = 2
END 
