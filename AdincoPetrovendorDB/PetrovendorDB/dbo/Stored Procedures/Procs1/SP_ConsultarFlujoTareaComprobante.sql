-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <26/11/19>
-- Description:	<consultar todos los flujos de aprobación de comprobante>
-- =============================================
CREATE PROCEDURE SP_ConsultarFlujoTareaComprobante @IdProveedor INT, 
                                                   @IdUsuario   INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        SELECT FT.IdFlujoTarea, 
               FT.Nombre, 
               FT.Descripcion, 
               TF.Nombre AS TipoFlujo, 
               A.IdAprobador, 
               A.NoSecuencia, 
               U.Nombre AS Aprobador, 
               U.IdUsuario
        FROM TA_FlujoTarea FT
             INNER JOIN TA_TipoFlujoTarea AS TF ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
             LEFT JOIN dbo.TA_Aprobador A ON A.IdFlujoTarea = FT.IdFlujoTarea
             LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = A.IdUsuario
        WHERE IdProveedor = @IdProveedor
              AND IdTipoOperacion = 16 --> TIPO COMPROBANTE
              AND ISNULL(Eliminado, 0) = 0
        ORDER BY FT.Nombre ASC;
    END;
