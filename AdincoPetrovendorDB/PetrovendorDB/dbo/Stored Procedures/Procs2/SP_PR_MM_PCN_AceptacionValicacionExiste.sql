-- =============================================
-- Author:		Daniel Cruz
-- Create date: 05-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionValicacionExiste]
	-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT
AS  ----EXECUTE [SP_PR_MM_PCN_AceptacionValicacionExiste] 46
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @TotalAceptaciones int
	DECLARE @TotalAceptacionesValidasPCN int 
	DECLARE @Response bit 

	SET @TotalAceptaciones = (SELECT COUNT(IdAceptacionPedidoDetalle)
							FROM MM_AceptacionPedidoDetalle AS APD
							INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido= APD.IdAceptacionPedido
							WHERE AP.IdAceptacionPedido= @IdAceptacionPedido)

	SET  @TotalAceptacionesValidasPCN = (SELECT COUNT(IdAceptacionPedidoDetalle)
							FROM MM_AceptacionPedidoDetalle AS APD
							INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido= APD.IdAceptacionPedido
							WHERE AP.IdAceptacionPedido= @IdAceptacionPedido AND APD.PCN_Agregado= 1)

	 IF 	@TotalAceptaciones = @TotalAceptacionesValidasPCN	
		 BEGIN
		  SET @Response = 1
		 END
	 ELSE
		 BEGIN 
			SET @Response = 0
		 END 			
        
		SELECT @Response AS Response 
     END;

