-- =============================================
-- Author:		Josue Glez
-- Create date:  05/9/2017
-- Description:	Obtiene documeto de matriz de evaluacion a partir de una solicitud de pedido en proceso de oferta
-- Author:		DAC
-- Create date:  07/9/2017
-- Description:	Actualice USE estaba apuntando hacia la bd master
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaDocMatrizOperacion]
-- 12284
	@IdSolicitudPedido int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT F.IdDocMatriz,
       F.NombreDoc,
       F.IdOperacion
FROM [TA_DocMatrizOperacion] F
WHERE F.IdOperacion = @IdSolicitudPedido;

END


