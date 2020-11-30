-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--**************************************************************
-- Modificado por:      <Jose Roman>								
-- Updated date: <09/01/2018>									
-- Description: <Se agrega la consulta de la firma>			
--**************************************************************
CREATE PROCEDURE [dbo].[SP_ConsultarAprobadoresAprobados] --1272
@IdPedido INT,
/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT TT.IdAprobador, 
			TT.NoSecuencia, 
			U.Nombre as Aprobadores, 
			TT.IdEstatus, 
			TE.Nombre, 
			TT.Comentario, 
			TT.FechaCambioEstatus,
			TT.IdTarea,
			CASE WHEN TT.IdEstatus = 2 THEN 'Aprobada' WHEN TT.IdEstatus = 1 THEN 'Pendiente' WHEN TT.IdEstatus = 3 THEN 'Rechazada' END AS Estado,
			tt.IdFirma
	FROM TA_Estatus TE
	INNER JOIN TA_Tarea TT 	ON TE.IdEstatus = TT.IdEstatus	
	INNER JOIN S_Usuario U	ON U.IdUsuario = TT.IdAprobador
	INNER JOIN TA_Operacion TAO ON TT.IdOperacion = TAO.IdOperacion
	INNER JOIN MM_Pedido AS P ON P.IdSolicitudPedido = TAO.IdDocumento
	WHERE  P.IdPedido = @IdPedido AND TAO.IdTipoOperacion = 9 
	AND P.Version= TAO.NoVersion
	ORDER BY TT.NoSecuencia ASC

	--- TT.IdEstatus = 2
END



