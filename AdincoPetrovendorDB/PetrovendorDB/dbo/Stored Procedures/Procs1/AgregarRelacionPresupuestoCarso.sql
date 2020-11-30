CREATE PROCEDURE AgregarRelacionPresupuestoCarso
@IdContrato INT,
@IdPresupuesto INT,
@PresupuestoAx NVARCHAR(MAX),
@IdUsuario INT
AS
BEGIN
    DECLARE @Anio INT

    SELECT @Anio = a.Anio
    FROM Adinco.dbo.CO_Presupuesto p
        INNER JOIN Adinco.dbo.CO_AnioContractual a
            ON a.IdAnioContractual = p.IdAnioContractual
    WHERE a.IdContrato = @IdContrato
          AND p.IdPresupuesto = @IdPresupuesto

    IF EXISTS (SELECT 1 FROM dbo.AX_AnioContractual WHERE AnioLinea = @PresupuestoAx)
    BEGIN
        RAISERROR('Clave de presupuesto de Ax ya registrado', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO dbo.AX_AnioContractual (AnioLinea, AnioReal, IdPresupuesto, CreadoPor, FechaCreacion)
        VALUES
        (   @PresupuestoAx, -- AnioLinea - nvarchar(100)
            @Anio,          -- AnioReal - int
            @IdPresupuesto, -- IdPresupuesto - int
            @IdUsuario, GETDATE())
    END
END








