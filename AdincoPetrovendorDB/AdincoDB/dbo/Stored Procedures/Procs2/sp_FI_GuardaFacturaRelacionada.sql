-- =============================================
-- Author:		Reyna Olvera
-- Create date: 06/07/2018
-- Description:	Inserta Facturas Relacionadas
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_GuardaFacturaRelacionada]
    -- Add the parameters for the stored procedure here
    @CFDIId INT,
    @TipoRelacion NVARCHAR(50),
    @UUID NVARCHAR(MAX),
    @NoParcialidad INT,
    @idusuario INT,
    @idcontrato INT
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO FI_CFdiRelacionados
    (
        CFDIId,
        TipoRelacion,
        UUID,
        NoParcialidad,
        idContrato,
        CreadoPor,
        CreadoEl,
        Activo
    )
    VALUES
    (@CFDIId, @TipoRelacion, @UUID, @NoParcialidad, @idcontrato, @idusuario, GETDATE(), 1);

    --Devuelve error o no
    IF @@ERROR <> 0
        SELECT 'false' AS msj;
    ELSE
        SELECT 'true' AS msj;
END;
