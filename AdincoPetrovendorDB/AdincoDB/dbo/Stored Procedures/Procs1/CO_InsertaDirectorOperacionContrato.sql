-- =============================================
-- Author:		Rena Olvera
-- Create date: 07/03/2018
-- Description:	Inserta un director de operacion
-- =============================================
CREATE PROCEDURE [dbo].[CO_InsertaDirectorOperacionContrato]
	-- Add the parameters for the stored procedure here
@IdDirector int,
@idContrato int,
@idRegion int,
@RazonSocial nvarchar(Max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @cont int;
			Select @cont= Count(idDirectorContrato) from CO_DirectorContrato where
			idDirector=@IdDirector And idContrato=@idContrato AND idRegion =@idRegion AND razonSocial=@RazonSocial;
		if(@cont>=1)
		Begin 
		Print('Ya se encuentra un Director de operacion con ese Contrato');
		end
			else
				begin
			INSERT INTO CO_DirectorContrato (idDirector,idContrato,idRegion,razonSocial  ) 
				 values(@IdDirector, @idContrato,@idRegion, @RazonSocial )
				 End
END


