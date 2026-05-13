-- =============================================
-- Author:		DANIEL AC
-- Create date: 20-09-17
-- Description:	Consultar FILTRO DE PROVEEDORES
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Consultar_Estados]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #ESTADO(IdEstado int, Nombre NVARCHAR(350))
	INSERT INTO #ESTADO(IdEstado, Nombre)
	VALUES (0,'Todos')

	INSERT INTO #ESTADO(IdEstado, Nombre)
	SELECT E.idEstado, E.Estado
	FROM PV_EstadoRepublica  AS E
	WHERE  E.IdPais= 42
	ORDER BY E.Estado ASC
	 
	SELECT * FROM #ESTADO 
END
