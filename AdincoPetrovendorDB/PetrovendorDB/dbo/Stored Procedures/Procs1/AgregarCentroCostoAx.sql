CREATE PROCEDURE AgregarCentroCostoAx
@IdProveedor INT,
@CentroCosto NVARCHAR(MAX),
@IdUsuario INT,
@IdCentroCostoAx NVARCHAR(MAX)
AS
BEGIN
    DECLARE @IdCentroCosto INT

    --si hay mas de 1 registro entonces se esta repitiendo arrojar la excepcion para que haga rollback
    IF EXISTS
    (   SELECT 1
        FROM dbo.AX_CENTROCOSTO ax
            INNER JOIN dbo.CC_CentroCosto c
                ON ax.IdCentroCostoPetrov = c.IdCentroCosto
        WHERE c.IdProveedor = @IdProveedor
              AND ax.IdCentroCostoAx = @IdCentroCostoAx)
    BEGIN
        RAISERROR('Id Centro Costo Ax ya registrado', 16, 1)
    END
    ELSE
    BEGIN
        DECLARE @Numero INT
        SELECT @Numero = MAX(CAST(Numero AS INT)) + 1
        FROM dbo.CC_CentroCosto
        WHERE IdProveedor = @IdProveedor

        INSERT INTO dbo.CC_CentroCosto
        (
            CentroCosto,
            IdProveedor,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            IsActivo,
            Numero
        )
        VALUES
        (   @CentroCosto,  -- CentroCosto - nvarchar(300)
            @IdProveedor,  -- IdProveedor - int
            @IdUsuario,    -- CreadoPor - int
            GETDATE(),     -- CreadoEl - datetime
            NULL,          -- ModificadoPor - int
            NULL,          -- ModificadoEl - datetime
            1,             -- IsActivo - bit
            LTRIM(@Numero) -- Numero - varchar(max)
        )


        SELECT @IdCentroCosto = SCOPE_IDENTITY()

        INSERT INTO dbo.AX_CENTROCOSTO (IdCentroCostoAx, IdCentroCostoPetrov)
        VALUES
        (   @IdCentroCostoAx, -- IdCentroCostoAx - nvarchar(200)
            @IdCentroCosto    -- IdCentroCostoPetrov - int
        )
    END



END







