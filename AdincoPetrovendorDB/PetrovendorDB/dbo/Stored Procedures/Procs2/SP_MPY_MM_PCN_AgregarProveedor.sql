-- =============================================
-- Author:		DANIEL AC
-- Create date: 13-04-2018
-- Description:	AGREGAR PROVEEDOR DEL PROVEEDOR DE PROCURA 
-- =============================================
CREATE procedure [dbo].[SP_MPY_MM_PCN_AgregarProveedor]

    @RazonSocial NVARCHAR(MAX),
    @RFC NVARCHAR(MAX),
    @IdProveedor NVARCHAR(20),
    @IdUsuario INT,
    @CorreoInvitacion NVARCHAR(MAX)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    /*VALIDAR QUE EL PROVEEDOR NO EXISTA*/
    DECLARE @ID_COUNT_PROVEEDOR INT = 0;
    SELECT @ID_COUNT_PROVEEDOR = COUNT(IdPCNProveedor)
    FROM dbo.MPY_MM_PCN_Proveedor
    WHERE RFC = @RFC
          AND IdProveedor = @IdProveedor;

    IF @ID_COUNT_PROVEEDOR = 0
    BEGIN
        INSERT INTO dbo.MPY_MM_PCN_Proveedor
        (
            RazonSocial,
            RFC,
            CreadoPor,
            CreadoEl,
            Activo,
            IdProveedor,
            CorreoInvitacion
        )
        VALUES
        (   @RazonSocial,     -- RazonSocial - nvarchar(max)
            @RFC,             -- RFC - nvarchar(max)
            @IdUsuario,       -- CreadoPor - int
            GETDATE(),        -- CreadoEl		
            1,                -- Activo - int
            @IdProveedor,     -- IdProveedor - int
            @CorreoInvitacion -- CorreoInvitacion - nvarchar(max)
            );

        DECLARE @ID_PROVEEDOR_NUEVO INT = (
                                              SELECT @@IDENTITY
                                          );
        SELECT 'PROVEEDOR_AGREGADO',
               @ID_PROVEEDOR_NUEVO;
    END;
    ELSE
    BEGIN
        SELECT 'RFC_YA_DISPONIBLE',
               0;
    END;




END;

