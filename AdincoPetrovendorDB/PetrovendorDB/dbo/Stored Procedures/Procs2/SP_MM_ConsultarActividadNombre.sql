-- =============================================
-- Author:		<Alexander G>
-- Create date: <02/01/2018>
-- Description:	<Sp para consultar el IdUnidad del la unidad por el nombre de la misma>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarActividadNombre] 
	-- Add the parameters for the stored procedure here
	@NombreActividad NVARCHAR(100),
	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME =NULL
  /*--------------------
  --------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SE CAMBIO EL SELECT A LIKE PORQUE HAY DATOS CON ESPACIOS INICIALES EN LA BASE DE DATOS Y AL USAR ESTA FUNCION EN LA IMPORTACION EN EL CATALOGO EL EXCEL ELIMINA LOS ESPACIOS INICIALES
	SELECT TOP 1 IdActividad FROM dbo.MM_BS_Actividad WHERE Nombre LIKE '%'+@NombreActividad+'%'

END
