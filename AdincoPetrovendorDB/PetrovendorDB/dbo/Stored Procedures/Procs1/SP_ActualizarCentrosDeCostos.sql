-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActualizarCentrosDeCostos]
@IdCentroCosto INT,
@CentroCosto NVARCHAR(MAX),
@numero varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[CC_CentroCosto] 
	SET [CentroCosto] =@CentroCosto,
		  [Numero] =@numero 
	WHERE [IdCentroCosto] = @IdCentroCosto

END

