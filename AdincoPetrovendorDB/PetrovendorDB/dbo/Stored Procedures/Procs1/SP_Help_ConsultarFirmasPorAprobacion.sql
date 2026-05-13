-- =============================================
-- Author:		Daniel Ac
-- Create date: 15-01-2018
-- Description:	consultar información de aprobadores de solcitud de pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_Help_ConsultarFirmasPorAprobacion] 	
@IdDocumento INT,
@IdTipoAprobacion INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
        

		SELECT T.IdTarea,T.IdFirma,T.IdAprobador,T.IdOperacion
		FROM dbo.MM_SolicitudPedido AS SP
		JOIN dbo.TA_Operacion AS O ON O.IdDocumento=SP.IdSolicitudPedido
		JOIN dbo.TA_Tarea AS T ON T.IdOperacion	= O.IdOperacion		
		WHERE O.IdDocumento=@IdDocumento 
		AND O.IdTipoOperacion=@IdTipoAprobacion --> CTE SOLPED
		AND LEN(ISNULL(T.IdFirma,''))=0
		AND T.IdEstatus <> 1 --> CTE QUE NO ESTE EN APROBACIÓN
		
        
     END;
