-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <17/6/2017>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectTipoDocumento]
@IdTipoRegimen int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select TD.IdTipoDocumento, TD.NombreTipoDocumento from  S_TipoDocumentoTipoPersona TTP 
inner join S_TipoRegimen TR on TTP.IdTipoRegimen = TR.IdTipoRegimen
inner join S_TipoDocumento TD on TTP.IdTipoDocumento = TD.IdTipoDocumento
where TTP.IdTipoRegimen = @IdTipoRegimen

END

