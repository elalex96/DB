-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarIdRepLegal]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT IdRepresentanteLegal FROM dbo.DG_RepresentanteLegal WHERE IdProveedor = @IdProveedor AND IsActivo = 1

END

