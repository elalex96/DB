-- Stored Procedure

-- =============================================
-- Author:		Miguel
-- Create date: 22/01/2018
-- Description:	Lista todo el menu para ocultarlo
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ListaMenu]
    -- Add the parameters for the stored procedure here
    @IdRol INT = 0,
    @IdUsuario INT = 0,
    @IdContrato INT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT MenuId,
           Clave,
           visible,
           idClasMenu,
           CreadoPor,
           CreadoEl,
           ModificadoPor,
           ModificadoEl,
           Activo,
           archivo,
           menupadre,
           descripcion,
           Orden
    FROM AP_MenuN
	where visible=1 ;
END;
