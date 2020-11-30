-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-02-2020
-- Description:	Validaciones del Presupuesto
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ValidacionesPresupuestos]
--[SP_CO_ValidacionesPresupuestos] 3,10113,0,'2019-10-01',3
-- Add the parameters for the stored procedure here
@IdContrato    INT, 
@IdUsuario     INT, 
@IdPresupuesto INT, 
@Accion        INT
AS
     BEGIN
         SET NOCOUNT ON;
         IF(@Accion = 1)
             BEGIN
                 SELECT CASE
                            WHEN IdPresupuestoCNH IS NULL
                                 OR IdPresupuestoCNH = ''
                                 OR IdPresupuestoCNH = 'FALTA ID'
                            THEN 'El presupuesto con Nombre: [ '+Nombre+' ] con fecha de finalización '+CONVERT(NVARCHAR(MAX), FinPresupuesto)+' la cual está fuera de los últimos 6 meses permitidos.'
                            ELSE 'El presupuesto: [ '+Nombre+' - '+SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH)-8, 9)+' ] con fecha de finalización '+CONVERT(NVARCHAR(MAX), FinPresupuesto)+' la cual está fuera de los últimos 6 meses permitidos.'
                        END AS Validaciones
                 FROM dbo.CO_Presupuesto
                 WHERE DATEDIFF(MONTH, FinPresupuesto, GETDATE()) >= 0
                       AND FinPresupuesto IS NOT NULL
                       AND IdPresupuesto = @IdPresupuesto;
             END;
         IF(@Accion = 2)
             BEGIN
                 SELECT CASE
                            WHEN IdPresupuestoCNH IS NULL
                                 OR IdPresupuestoCNH = ''
                                 OR IdPresupuestoCNH = 'FALTA ID'
                            THEN 'La plantilla esta vacia ya que el presupuesto con Nombre: [ '+Nombre+' ] con fecha de finalización '+CONVERT(NVARCHAR(MAX), FinPresupuesto)+' esta fuera del periodo.'
                            ELSE 'La plantilla esta vacia ya que el presupuesto: [ '+Nombre+' - '+SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH)-8, 9)+' ] con fecha de finalización '+CONVERT(NVARCHAR(MAX), FinPresupuesto)+' la cual está fuera del periodo.'
                        END AS Validaciones
                 FROM dbo.CO_Presupuesto
                 WHERE DATEDIFF(MONTH, FinPresupuesto, GETDATE()) >= 0
                       AND FinPresupuesto IS NOT NULL
                       AND IdPresupuesto = @IdPresupuesto;
             END;
     END;