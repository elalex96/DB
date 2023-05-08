-- =============================================
-- Author:		Reyna Olvera 
-- Create date: 07/03/2018
-- Description:	Modifica Un director de operacion
-- =============================================
CREATE PROCEDURE [dbo].[CO_ModificaDirectorOperacionContrato]
	-- Add the parameters for the stored procedure here
		@IdDirector int, 
           @idContrato int,
           @idRegion int,
            @RazonSocial nvarchar(Max),
            @idDirectorContrato int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE CO_DirectorContrato SET 
		 idDirector = @IdDirector, idContrato = @idContrato, idRegion = @idRegion,
		  razonSocial = @RazonSocial WHERE (idDirectorContrato = @idDirectorContrato)
END

