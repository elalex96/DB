-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/11/2018
-- Description:	Consultas de usuario de la carga 
-- =============================================
create procedure [dbo].[SP_MPY_UsuarioPreFactura]
	-- Add the parameters for the stored procedure here
	@IdPRESES INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		US.IdUsuario,
		US.Nombre,
		US.Correo
	FROM Adinco.dbo.CO_SAPPRESES AS PSES
	LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = PSES.CreadoPor
	WHERE PSES.IdPRESES = @IdPRESES
END
