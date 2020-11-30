-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarEstatusOperacionCatalogoTemporal]
@IdOperacion INT 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT TE.IdEstatus,TE.Nombre
	FROM TA_Operacion O 
	INNER JOIN TA_Estatus TE ON O.IdEstatusOperacion = TE.IdEstatus
	WHERE O.IdOperacion = @IdOperacion

END

