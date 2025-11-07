use petrovendor
go
drop proc if exists USP_INS_UPD_PreferenciaContrato
go
create proc USP_INS_UPD_PreferenciaContrato
@Id int,
@ContratoId int,
@PreferenciaId int,
@Valor varchar(1000),
@Activo bit,
@CreadoPor int
as
begin
SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM AP_PreferenciaContrato WHERE Id = @Id)
    BEGIN
        -- Validar si ya existe otro registro con el mismo ContratoId y PreferenciaId
        IF EXISTS (SELECT 1 
                   FROM AP_PreferenciaContrato 
                   WHERE ContratoId = @ContratoId
                     AND PreferenciaId = @PreferenciaId)
        BEGIN
            RAISERROR('Ya existe un registro con las mismas configuraciones.', 16, 1);
            RETURN;
        END
        INSERT INTO AP_PreferenciaContrato
            (ContratoId, PreferenciaId, Valor, Activo, CreadoEl, CreadoPor)
        VALUES
            (@ContratoId, @PreferenciaId, @Valor, @Activo, GETDATE(), @CreadoPor);
    END
    ELSE
    BEGIN
        -- Validar si ya existe otro registro (distinto del actual) con el mismo ContratoId y PreferenciaId
        IF EXISTS (SELECT 1 
                   FROM AP_PreferenciaContrato 
                   WHERE ContratoId = @ContratoId
                     AND PreferenciaId = @PreferenciaId
                     AND Id <> @Id)
        BEGIN
            RAISERROR('Ya existe otro contrato con la preferencia seleccionada.', 16, 1);
            RETURN;
        END
        UPDATE AP_PreferenciaContrato
        SET
            ContratoId = @ContratoId,
            PreferenciaId = @PreferenciaId,
            Valor = @Valor,
            Activo = @Activo,
            ModificadoEl = GETDATE(),
            ModificadoPor = @CreadoPor
        WHERE Id = @Id;
    END
end