-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ComentarioSolicitudRechazadaCtaBancaria]
@Comentario nvarchar(max),
@IdCuentaBancaria int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update PV_DocumentoCuentaBancaria
	set
   ComentarioCancelacion = @Comentario,
   EstatusAprobacion = 3
   where IdCuentaBancaria = @IdCuentaBancaria

END

