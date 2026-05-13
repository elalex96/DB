-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarCentrosDeCostos]
@CentroCosto   NVARCHAR(300),
@IdProveedor   INT,
@CreadoPor     INT,
@numero		 Varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[CC_CentroCosto](
	 CentroCosto,
     IdProveedor,
     CreadoPor,
     CreadoEl,
	 IsActivo,
	 Numero
	)
	VALUES(
	@CentroCosto,
	@IdProveedor,
	@CreadoPor,
	GETDATE(),
	1,
	@numero
	)

	SELECT (@@IDENTITY);

END

