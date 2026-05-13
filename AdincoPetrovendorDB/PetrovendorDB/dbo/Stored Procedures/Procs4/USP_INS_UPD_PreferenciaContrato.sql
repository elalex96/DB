USE [Petrovendor]
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_UPD_PreferenciaContrato'
)
    DROP PROCEDURE USP_INS_UPD_PreferenciaContrato;

GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 30/08/2022
-- Modified:	Alexander Gomez - 27/04/2026
-- Description:	Crea un nuevo registro, validando previamente que no 
--              exista ya la misma combinación de contrato (@ContratoId) y 
--              preferencia (@PreferenciaId) para evitar duplicados.
-- =============================================
CREATE PROC [dbo].[USP_INS_UPD_PreferenciaContrato]
    @Id int,
    @ContratoId int,
    @PreferenciaId int,
    @Valor varchar(1000),
    @Activo bit,
    @CreadoPor int
as
begin
SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM AP_PreferenciaContrato (NOLOCK) WHERE Id = @Id)
    BEGIN
        IF EXISTS (SELECT 1 FROM AP_PreferenciaContrato (NOLOCK)
                   WHERE ContratoId = @ContratoId AND PreferenciaId = @PreferenciaId)
        BEGIN
            RAISERROR('Ya existe un registro con las mismas configuraciones.', 16, 1);
            RETURN;
        END
        INSERT INTO AP_PreferenciaContrato (ContratoId, PreferenciaId, Valor, Activo, CreadoEl, CreadoPor)
        VALUES (@ContratoId, @PreferenciaId, @Valor, @Activo, GETDATE(), @CreadoPor);
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM AP_PreferenciaContrato (NOLOCK)
                   WHERE ContratoId = @ContratoId AND PreferenciaId = @PreferenciaId AND Id <> @Id)
        BEGIN
            RAISERROR('Ya existe otro contrato con la preferencia seleccionada.', 16, 1);
            RETURN;
        END
        UPDATE AP_PreferenciaContrato
        SET ContratoId = @ContratoId, PreferenciaId = @PreferenciaId,
            Valor = @Valor, Activo = @Activo,
            ModificadoEl = GETDATE(), ModificadoPor = @CreadoPor
        WHERE Id = @Id;
    END
end
