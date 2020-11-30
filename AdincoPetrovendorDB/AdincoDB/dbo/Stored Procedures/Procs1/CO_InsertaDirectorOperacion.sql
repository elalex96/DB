-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/2018
-- Description:	Inserta un director para poder ser ligado a los contratos
-- =============================================
CREATE PROCEDURE [dbo].[CO_InsertaDirectorOperacion]
	-- Add the parameters for the stored procedure here
	@NombreCompleto nvarchar(Max),
	@idUsuario int =0,
	@idContrato int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @cont int;
	Select @cont= Count(idDirector) from CO_DirectorOperaciones where NombreCompleto=@NombreCompleto
	if(@cont>=1)
	Begin 
	Print('Ya se encuentra un Director de operacion con ese nombre');
	end
	else
	begin
	INSERT INTO CO_DirectorOperaciones(NombreCompleto) VALUES (@NombreCompleto)
	end
	
END

