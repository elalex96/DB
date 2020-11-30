CREATE PROC p_CNH_FormatoInversiones_General @pIdContrato INT
AS
     SELECT Contrato = NumeroContrato, 
            FechaEfectiva = CONVERT(VARCHAR, InicioVigencia, 103), 
            Contratista = con.NombreContratista, 
            Operador = '',
            --
            Plan0 = '', 
            FechaPresentacionPlan = '', 
            VigenciaPlan = '', 
            VigenciaPlan1 = '', 
            ModificacionesPlan = '', 
            FechaModificacionPlan = '',
            --
            ProgramaAsociado = '', 
            FechaPresentacionPrograma = '', 
            VigenciaPrograma = '', 
            VigenciaPrograma1 = '', 
            ModificacionesPrograma = '', 
            FechaModificacionPrograma = ''
     FROM CO_Contrato c
          INNER JOIN CO_Contratista con ON con.IdContratista = c.IdContratista
     WHERE c.IdContrato = @pIdContrato;