
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 04-06-18
-- Description: Consultar estatus actual de aprobador  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarEstatusAprobador] 
    -- Add the parameters for the stored procedure here
    
    @IdUsuario INT,      
    @IdOperacion INT,
	@IdContrato INT = NULL,
	@IdSolicitudPedido INT=NULL, 
	@IdVersion INT =NULL,
	@Tipo NVARCHAR(50) =NULL 
  
  
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	IF @Tipo IS NULL OR @Tipo = 'SOLICITUD_PEDIDO'
	BEGIN 
		SELECT dbo.TA_Tarea.IdEstatus,dbo.TA_Operacion.IdDocumento FROM  dbo.TA_Tarea
		INNER JOIN dbo.TA_Operacion ON TA_Operacion.IdOperacion = TA_Tarea.IdOperacion
		WHERE IdAprobador=@IdUsuario AND  TA_Operacion.IdOperacion=@IdOperacion
	END 

	IF @Tipo IS NULL OR @Tipo = 'PEDIDO'
	BEGIN 
		SELECT dbo.TA_Tarea.IdEstatus,dbo.TA_Operacion.IdDocumento,TA_Operacion.IdOperacion FROM  dbo.TA_Tarea
		INNER JOIN dbo.TA_Operacion ON TA_Operacion.IdOperacion = TA_Tarea.IdOperacion
		WHERE IdAprobador=@IdUsuario AND  TA_Operacion.IdDocumento=@IdSolicitudPedido AND TA_Operacion.NoVersion= @IdVersion AND dbo.TA_Operacion.IdTipoOperacion=9 --> Aprobación de pedido 
	END  

END 

