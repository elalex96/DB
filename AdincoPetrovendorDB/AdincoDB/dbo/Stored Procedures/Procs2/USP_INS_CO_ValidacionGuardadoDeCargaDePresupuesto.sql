IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CO_ValidacionGuardadoDeCargaDePresupuesto'
    )
    DROP PROCEDURE USP_INS_CO_ValidacionGuardadoDeCargaDePresupuesto
GO
CREATE PROCEDURE USP_INS_CO_ValidacionGuardadoDeCargaDePresupuesto
    @UsuarioId INT,
    @ContratoId INT,
    @IdArchivoAWS INT,
    @IdContratoSeleccionado INT,
    @FechaInicio DATE,
    @FechaFin DATE,
    @Programa VARCHAR(100),
    @Presupuesto VARCHAR(100),
    @AdjuntarClaveSubtarea BIT = 0,
    @Table_CO_Type_BitacoraPresupuestoDetalle CO_Type_BitacoraPresupuestoDetalle READONLY,
	@IdTipoProgramaActividad  INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN

        SET NOCOUNT ON;

        DECLARE @ErrorMessage VARCHAR(4000),
                @DetalleAnalisis VARCHAR(8000),
                @DetalleAnalisisServicios VARCHAR(8000),
                @DetalleAnalisisInstalaciones VARCHAR(8000),
                @DetalleAnalisisDatosGenerales VARCHAR(8000),
                @IdCarga INT = 0,
                @IdAreaContractual INT = 0,
                @NumeroAlertasServicio INT = 0,
                @NumeroAlertasInstalacion INT = 0,
                @NumeroAlertasDatosGenerales INT = 0,
                @Mensaje VARCHAR(50) = '';

        SELECT TOP 1
            @IdAreaContractual = IdAreaContractual
        FROM CO_Contrato (NOLOCK)
        WHERE IdContrato = @IdContratoSeleccionado

        CREATE TABLE #TablaTemporalValidacionServicio
        (
            IdSubtarea VARCHAR(100) NULL,
            Subtarea_Servicio VARCHAR(1000) NULL,
            Existe BIT NULL,
            Activo BIT NULL,
            NumeroRepetidas INT NULL
        )

        CREATE TABLE #TablaTemporalValidacionInstalacion
        (
            Pozo_Instalacion VARCHAR(100) NULL,
            Existe BIT NULL,
            Activo BIT NULL,
            NumeroRepetidas INT NULL
        )

        CREATE TABLE #TablaTemporalValidacionDetalles
        (
            Tipo VARCHAR(100) NULL,
            Descripcion VARCHAR(1000) NULL,
            TipoDetalle VARCHAR(100) NULL,
            MultiplesDetalles BIT NULL,
            NumeroDeDetalles INT NULL
        )

        CREATE TABLE #TablaTemporalBitacoraPresupuestoDetalle
        (
            IdDetalle INT NULL,
            IdActividadPetrolera VARCHAR(100) NULL,
            ActividadPetrolera VARCHAR(1000) NULL,
            IdSubactividadPetrolera VARCHAR(100) NULL,
            SubactividadPetrolera VARCHAR(1000) NULL,
            IdTarea VARCHAR(100) NULL,
            Tarea VARCHAR(1000) NULL,
            IdSubtarea VARCHAR(100) NULL,
            Subtarea_Servicio VARCHAR(1000) NULL,
            Elegible VARCHAR(100) NULL,
            Area VARCHAR(100) NULL,
            Campo VARCHAR(100) NULL,
            Yacimiento VARCHAR(100) NULL,
            Pozo_Instalacion VARCHAR(100) NULL,
            CAPEX_OPEX VARCHAR(100) NULL,
            PA_17 FLOAT NULL,
            PA_18 FLOAT NULL,
            PA_19 FLOAT NULL,
            PA_20 FLOAT NULL,
            PA_21 FLOAT NULL,
            PA_22 FLOAT NULL,
            PA_23 FLOAT NULL,
            PA_24 FLOAT NULL,
            PA_25 FLOAT NULL,
            PA_26 FLOAT NULL,
            PA_27 FLOAT NULL,
            PA_28 FLOAT NULL,
            PA_29 FLOAT NULL,
            PA_30 FLOAT NULL,
            PA_31 FLOAT NULL,
            PA_32 FLOAT NULL,
            PA_33 FLOAT NULL,
            PA_34 FLOAT NULL,
            PA_35 FLOAT NULL,
            PA_36 FLOAT NULL,
            PA_37 FLOAT NULL,
            PA_38 FLOAT NULL,
            PA_39 FLOAT NULL,
            PA_40 FLOAT NULL,
            PA_41 FLOAT NULL,
            PA_42 FLOAT NULL,
            PA_43 FLOAT NULL,
            PA_44 FLOAT NULL,
            PA_45 FLOAT NULL,
            PA_46 FLOAT NULL,
            PA_47 FLOAT NULL,
            PA_48 FLOAT NULL,
            PA_49 FLOAT NULL,
            PA_50 FLOAT NULL,
            PA_51 FLOAT NULL,
            PA_52 FLOAT NULL,
            PA_53 FLOAT NULL,
            PA_54 FLOAT NULL,
            PA_55 FLOAT NULL,
            PA_56 FLOAT NULL,
            PA_57 FLOAT NULL,
            PA_58 FLOAT NULL,
            PA_59 FLOAT NULL,
            PA_60 FLOAT NULL,
            PA_61 FLOAT NULL,
            PA_62 FLOAT NULL,
            PA_63 FLOAT NULL,
            PA_64 FLOAT NULL,
            PA_65 FLOAT NULL,
            PA_66 FLOAT NULL,
            PA_67 FLOAT NULL,
            PA_68 FLOAT NULL,
            PA_69 FLOAT NULL,
            PA_70 FLOAT NULL,
            PA_71 FLOAT NULL,
            PA_72 FLOAT NULL,
            PA_73 FLOAT NULL,
            PA_74 FLOAT NULL,
            PA_75 FLOAT NULL,
            PA_76 FLOAT NULL,
            PA_77 FLOAT NULL,
            PA_78 FLOAT NULL,
            PA_79 FLOAT NULL,
            PA_80 FLOAT NULL,
            PA_81 FLOAT NULL,
            PA_82 FLOAT NULL,
            PA_83 FLOAT NULL,
            PA_84 FLOAT NULL,
            PA_85 FLOAT NULL,
            PA_86 FLOAT NULL,
            PA_87 FLOAT NULL,
            PA_88 FLOAT NULL,
            PA_89 FLOAT NULL,
            PA_90 FLOAT NULL,
            PA_91 FLOAT NULL,
            PA_92 FLOAT NULL,
            PA_93 FLOAT NULL,
            PA_94 FLOAT NULL,
            PA_95 FLOAT NULL,
            PA_96 FLOAT NULL,
            PA_97 FLOAT NULL,
            PA_98 FLOAT NULL,
            PA_99 FLOAT NULL,
            PA_100 FLOAT NULL,
            PA_101 FLOAT NULL,
            PA_102 FLOAT NULL,
            PA_103 FLOAT NULL,
            PA_104 FLOAT NULL,
            PA_105 FLOAT NULL,
            PA_106 FLOAT NULL,
            PA_107 FLOAT NULL,
            PA_108 FLOAT NULL,
            PA_109 FLOAT NULL,
            PA_110 FLOAT NULL,
            PA_111 FLOAT NULL,
            PA_112 FLOAT NULL,
            PA_113 FLOAT NULL,
            PA_114 FLOAT NULL,
            PA_115 FLOAT NULL,
            PA_116 FLOAT NULL,
            PA_117 FLOAT NULL,
            PA_118 FLOAT NULL,
            PA_119 FLOAT NULL,
            PA_120 FLOAT NULL,
            PA_121 FLOAT NULL,
            PA_122 FLOAT NULL,
            PA_123 FLOAT NULL,
            PA_124 FLOAT NULL,
            PA_125 FLOAT NULL,
            PA_126 FLOAT NULL,
            PA_127 FLOAT NULL,
            PA_128 FLOAT NULL,
            PA_129 FLOAT NULL,
            PA_130 FLOAT NULL,
            PA_131 FLOAT NULL,
            PA_132 FLOAT NULL,
            PA_133 FLOAT NULL,
            PA_134 FLOAT NULL,
            PA_135 FLOAT NULL,
            PA_136 FLOAT NULL,
            PA_137 FLOAT NULL,
            PA_138 FLOAT NULL,
            PA_139 FLOAT NULL,
            PA_140 FLOAT NULL,
            PA_141 FLOAT NULL,
            PA_142 FLOAT NULL,
            PA_143 FLOAT NULL,
            PA_144 FLOAT NULL,
            PA_145 FLOAT NULL,
            PA_146 FLOAT NULL,
            PA_147 FLOAT NULL,
            PA_148 FLOAT NULL,
            PA_149 FLOAT NULL,
            PA_150 FLOAT NULL,
            PA_151 FLOAT NULL,
            PA_152 FLOAT NULL,
            PA_153 FLOAT NULL,
            PA_154 FLOAT NULL,
            PA_155 FLOAT NULL,
            PA_156 FLOAT NULL,
            PA_157 FLOAT NULL,
            PA_158 FLOAT NULL,
            PA_159 FLOAT NULL,
            PA_160 FLOAT NULL,
            PA_161 FLOAT NULL,
            PA_162 FLOAT NULL,
            PA_163 FLOAT NULL,
            PA_164 FLOAT NULL,
            PA_165 FLOAT NULL,
            PA_166 FLOAT NULL,
            PA_167 FLOAT NULL,
            PA_168 FLOAT NULL,
            PA_169 FLOAT NULL,
            PA_170 FLOAT NULL,
            PA_171 FLOAT NULL,
            PA_172 FLOAT NULL,
            PA_173 FLOAT NULL,
            PA_174 FLOAT NULL,
            PA_175 FLOAT NULL,
            PA_176 FLOAT NULL,
            PA_177 FLOAT NULL,
            PA_178 FLOAT NULL,
            PA_179 FLOAT NULL,
            PA_180 FLOAT NULL,
            PA_181 FLOAT NULL,
            PA_182 FLOAT NULL,
       PA_183 FLOAT NULL,
        PA_184 FLOAT NULL,
            PA_185 FLOAT NULL,
            PA_186 FLOAT NULL,
            PA_187 FLOAT NULL,
            PA_188 FLOAT NULL,
            PA_189 FLOAT NULL,
            PA_190 FLOAT NULL,
            PA_191 FLOAT NULL,
            PA_192 FLOAT NULL,
            PA_193 FLOAT NULL,
            PA_194 FLOAT NULL,
            PA_195 FLOAT NULL,
            PA_196 FLOAT NULL,
            PA_197 FLOAT NULL,
            PA_198 FLOAT NULL,
            PA_199 FLOAT NULL,
            PA_200 FLOAT NULL,
            PA_201 FLOAT NULL,
            PA_202 FLOAT NULL,
            PA_203 FLOAT NULL,
            PA_204 FLOAT NULL,
            PA_205 FLOAT NULL,
            PA_206 FLOAT NULL,
            PA_207 FLOAT NULL,
            PA_208 FLOAT NULL,
            PA_209 FLOAT NULL,
            PA_210 FLOAT NULL,
            PA_211 FLOAT NULL,
            PA_212 FLOAT NULL,
            PA_213 FLOAT NULL,
            PA_214 FLOAT NULL,
            PA_215 FLOAT NULL,
            PA_216 FLOAT NULL,
            PA_217 FLOAT NULL,
            PA_218 FLOAT NULL,
            PA_219 FLOAT NULL,
            PA_220 FLOAT NULL,
            PA_221 FLOAT NULL,
            PA_222 FLOAT NULL,
            PA_223 FLOAT NULL,
            PA_224 FLOAT NULL,
            PA_225 FLOAT NULL,
            PA_226 FLOAT NULL,
            PA_227 FLOAT NULL,
            PA_228 FLOAT NULL,
            PA_229 FLOAT NULL,
            PA_230 FLOAT NULL,
            PA_231 FLOAT NULL,
            PA_232 FLOAT NULL,
            PA_233 FLOAT NULL,
            PA_234 FLOAT NULL,
            PA_235 FLOAT NULL,
            PA_236 FLOAT NULL,
            PA_237 FLOAT NULL,
            PA_238 FLOAT NULL,
            PA_239 FLOAT NULL,
            PA_240 FLOAT NULL,
            PA_241 FLOAT NULL,
            PA_242 FLOAT NULL,
            PA_243 FLOAT NULL,
            PA_244 FLOAT NULL,
            PA_245 FLOAT NULL,
            PA_246 FLOAT NULL,
            PA_247 FLOAT NULL,
            PA_248 FLOAT NULL,
            PA_249 FLOAT NULL,
            PA_250 FLOAT NULL,
            PA_251 FLOAT NULL,
            PA_252 FLOAT NULL,
            PA_253 FLOAT NULL,
            PA_254 FLOAT NULL,
            PA_255 FLOAT NULL,
            PA_256 FLOAT NULL,
            MONTO FLOAT NULL,
			NumeroRenglon INT NULL
        );

        INSERT INTO CO_BitacoraPresupuesto
        (
       IdArchivoAWS,
            IdContrato,
            Inicio,
            Fin,
            CreadoEl,
            CreadoPor,
            chkAdjuntaClaveSubTarea,
			IdTipoProgramaActividad 
        )
        VALUES
        (@IdArchivoAWS, @IdContratoSeleccionado, @FechaInicio, @FechaFin, GETDATE(), @UsuarioId, @AdjuntarClaveSubtarea, @IdTipoProgramaActividad)

        SELECT @IdCarga = SCOPE_IDENTITY()

        INSERT INTO CO_BitacoraPresupuestoDetalle
        (
            IdCarga,
            IdDetalle,
            IdActividadPetrolera,
            ActividadPetrolera,
            IdSubactividadPetrolera,
            SubactividadPetrolera,
            IdTarea,
            Tarea,
            IdSubtarea,
            Subtarea_Servicio,
            Elegible,
            Area,
            Campo,
            Yacimiento,
            Pozo_Instalacion,
            CAPEX_OPEX,
            PA_17,
            PA_18,
            PA_19,
            PA_20,
            PA_21,
            PA_22,
            PA_23,
            PA_24,
            PA_25,
            PA_26,
            PA_27,
            PA_28,
            PA_29,
            PA_30,
            PA_31,
            PA_32,
            PA_33,
            PA_34,
            PA_35,
            PA_36,
            PA_37,
            PA_38,
            PA_39,
            PA_40,
            PA_41,
            PA_42,
            PA_43,
            PA_44,
            PA_45,
            PA_46,
            PA_47,
            PA_48,
            PA_49,
            PA_50,
            PA_51,
            PA_52,
            PA_53,
            PA_54,
            PA_55,
            PA_56,
            PA_57,
            PA_58,
            PA_59,
            PA_60,
            PA_61,
            PA_62,
            PA_63,
            PA_64,
            PA_65,
            PA_66,
            PA_67,
            PA_68,
            PA_69,
            PA_70,
            PA_71,
            PA_72,
            PA_73,
            PA_74,
            PA_75,
            PA_76,
            PA_77,
            PA_78,
            PA_79,
            PA_80,
            PA_81,
            PA_82,
            PA_83,
            PA_84,
            PA_85,
            PA_86,
            PA_87,
            PA_88,
            PA_89,
            PA_90,
            PA_91,
            PA_92,
            PA_93,
            PA_94,
            PA_95,
            PA_96,
            PA_97,
            PA_98,
            PA_99,
            PA_100,
            PA_101,
            PA_102,
            PA_103,
            PA_104,
            PA_105,
            PA_106,
            PA_107,
            PA_108,
            PA_109,
            PA_110,
            PA_111,
            PA_112,
            PA_113,
            PA_114,
            PA_115,
            PA_116,
            PA_117,
            PA_118,
            PA_119,
            PA_120,
            PA_121,
            PA_122,
            PA_123,
            PA_124,
            PA_125,
            PA_126,
            PA_127,
            PA_128,
            PA_129,
            PA_130,
            PA_131,
            PA_132,
            PA_133,
            PA_134,
            PA_135,
            PA_136,
            PA_137,
            PA_138,
            PA_139,
            PA_140,
            PA_141,
            PA_142,
            PA_143,
            PA_144,
            PA_145,
            PA_146,
            PA_147,
            PA_148,
            PA_149,
            PA_150,
            PA_151,
            PA_152,
            PA_153,
            PA_154,
            PA_155,
            PA_156,
            PA_157,
            PA_158,
            PA_159,
            PA_160,
            PA_161,
            PA_162,
            PA_163,
            PA_164,
            PA_165,
            PA_166,
            PA_167,
            PA_168,
            PA_169,
 PA_170,
            PA_171,
            PA_172,
            PA_173,
            PA_174,
            PA_175,
            PA_176,
            PA_177,
            PA_178,
            PA_179,
            PA_180,
            PA_181,
            PA_182,
            PA_183,
            PA_184,
            PA_185,
            PA_186,
            PA_187,
            PA_188,
            PA_189,
            PA_190,
            PA_191,
            PA_192,
            PA_193,
            PA_194,
            PA_195,
            PA_196,
            PA_197,
            PA_198,
            PA_199,
            PA_200,
            PA_201,
            PA_202,
            PA_203,
            PA_204,
            PA_205,
            PA_206,
            PA_207,
            PA_208,
            PA_209,
            PA_210,
            PA_211,
            PA_212,
            PA_213,
            PA_214,
            PA_215,
            PA_216,
            PA_217,
            PA_218,
            PA_219,
            PA_220,
            PA_221,
            PA_222,
            PA_223,
            PA_224,
            PA_225,
            PA_226,
            PA_227,
            PA_228,
            PA_229,
            PA_230,
            PA_231,
            PA_232,
            PA_233,
            PA_234,
            PA_235,
            PA_236,
            PA_237,
            PA_238,
            PA_239,
            PA_240,
            PA_241,
            PA_242,
            PA_243,
            PA_244,
            PA_245,
            PA_246,
            PA_247,
            PA_248,
            PA_249,
            PA_250,
            PA_251,
            PA_252,
            PA_253,
            PA_254,
            PA_255,
            PA_256        )
        SELECT @IdCarga,
               IdDetalle,
               IdActividadPetrolera,
               ActividadPetrolera,
               IdSubactividadPetrolera,
               SubactividadPetrolera,
               IdTarea,
               Tarea,
               IdSubtarea,
               Subtarea_Servicio,
               Elegible,
               Area,
               Campo,
               Yacimiento,
               Pozo_Instalacion,
               CAPEX_OPEX,
               PA_17,
               PA_18,
               PA_19,
               PA_20,
               PA_21,
               PA_22,
               PA_23,
               PA_24,
               PA_25,
               PA_26,
               PA_27,
               PA_28,
               PA_29,
               PA_30,
               PA_31,
               PA_32,
               PA_33,
               PA_34,
               PA_35,
               PA_36,
               PA_37,
               PA_38,
               PA_39,
               PA_40,
               PA_41,
               PA_42,
               PA_43,
               PA_44,
               PA_45,
               PA_46,
               PA_47,
               PA_48,
               PA_49,
               PA_50,
               PA_51,
               PA_52,
               PA_53,
               PA_54,
               PA_55,
               PA_56,
               PA_57,
               PA_58,
               PA_59,
               PA_60,
               PA_61,
               PA_62,
               PA_63,
               PA_64,
               PA_65,
               PA_66,
               PA_67,
               PA_68,
               PA_69,
               PA_70,
               PA_71,
               PA_72,
               PA_73,
               PA_74,
               PA_75,
               PA_76,
               PA_77,
               PA_78,
               PA_79,
               PA_80,
               PA_81,
               PA_82,
               PA_83,
               PA_84,
               PA_85,
               PA_86,
               PA_87,
               PA_88,
               PA_89,
               PA_90,
               PA_91,
               PA_92,
               PA_93,
               PA_94,
               PA_95,
               PA_96,
               PA_97,
               PA_98,
               PA_99,
               PA_100,
               PA_101,
               PA_102,
               PA_103,
               PA_104,
               PA_105,
               PA_106,
               PA_107,
               PA_108,
               PA_109,
               PA_110,
               PA_111,
               PA_112,
               PA_113,
               PA_114,
               PA_115,
               PA_116,
               PA_117,
               PA_118,
               PA_119,
               PA_120,
               PA_121,
               PA_122,
               PA_123,
               PA_124,
               PA_125,
               PA_126,
               PA_127,
               PA_128,
               PA_129,
               PA_130,
               PA_131,
               PA_132,
               PA_133,
               PA_134,
               PA_135,
               PA_136,
               PA_137,
               PA_138,
               PA_139,
               PA_140,
               PA_141,
               PA_142,
               PA_143,
               PA_144,
               PA_145,
               PA_146,
               PA_147,
               PA_148,
               PA_149,
               PA_150,
               PA_151,
               PA_152,
               PA_153,
               PA_154,
               PA_155,
               PA_156,
               PA_157,
               PA_158,
               PA_159,
               PA_160,
               PA_161,
               PA_162,
               PA_163,
               PA_164,
               PA_165,
               PA_166,
               PA_167,
               PA_168,
               PA_169,
               PA_170,
               PA_171,
               PA_172,
               PA_173,
               PA_174,
               PA_175,
               PA_176,
               PA_177,
               PA_178,
               PA_179,
               PA_180,
               PA_181,
               PA_182,
               PA_183,
               PA_184,
               PA_185,
               PA_186,
               PA_187,
               PA_188,
               PA_189,
               PA_190,
               PA_191,
               PA_192,
               PA_193,
               PA_194,
               PA_195,
               PA_196,
               PA_197,
               PA_198,
               PA_199,
               PA_200,
               PA_201,
               PA_202,
               PA_203,
               PA_204,
               PA_205,
               PA_206,
               PA_207,
               PA_208,
               PA_209,
               PA_210,
               PA_211,
               PA_212,
               PA_213,
               PA_214,
               PA_215,
               PA_216,
               PA_217,
               PA_218,
               PA_219,
               PA_220,
               PA_221,
               PA_222,
               PA_223,
               PA_224,
               PA_225,
               PA_226,
               PA_227,
               PA_228,
               PA_229,
               PA_230,
               PA_231,
               PA_232,
               PA_233,
               PA_234,
               PA_235,
               PA_236,
               PA_237,
               PA_238,
               PA_239,
               PA_240,
               PA_241,
               PA_242,
               PA_243,
               PA_244,
               PA_245,
               PA_246,
               PA_247,
               PA_248,
               PA_249,
               PA_250,
               PA_251,
               PA_252,
               PA_253,
               PA_254,
               PA_255,
               PA_256
        FROM @Table_CO_Type_BitacoraPresupuestoDetalle;

        INSERT INTO #TablaTemporalBitacoraPresupuestoDetalle
        (
            IdDetalle,
            IdActividadPetrolera,
            ActividadPetrolera,
            IdSubactividadPetrolera,
            SubactividadPetrolera,
            IdTarea,
            Tarea,
            IdSubtarea,
            Subtarea_Servicio,
            Elegible,
            Area,
            Campo,
            Yacimiento,
            Pozo_Instalacion,
            CAPEX_OPEX,
            PA_17,
            PA_18,
            PA_19,
            PA_20,
            PA_21,
            PA_22,
            PA_23,
            PA_24,
            PA_25,
            PA_26,
            PA_27,
            PA_28,
            PA_29,
            PA_30,
            PA_31,
            PA_32,
            PA_33,
            PA_34,
            PA_35,
            PA_36,
            PA_37,
            PA_38,
            PA_39,
            PA_40,
            PA_41,
            PA_42,
            PA_43,
            PA_44,
            PA_45,
            PA_46,
            PA_47,
            PA_48,
            PA_49,
            PA_50,
            PA_51,
            PA_52,
            PA_53,
            PA_54,
            PA_55,
            PA_56,
            PA_57,
            PA_58,
            PA_59,
            PA_60,
            PA_61,
            PA_62,
            PA_63,
            PA_64,
            PA_65,
            PA_66,
            PA_67,
            PA_68,
            PA_69,
            PA_70,
            PA_71,
            PA_72,
            PA_73,
            PA_74,
            PA_75,
            PA_76,
            PA_77,
            PA_78,
PA_79,
            PA_80,
            PA_81,
            PA_82,
            PA_83,
            PA_84,
            PA_85,
            PA_86,
            PA_87,
            PA_88,
            PA_89,
            PA_90,
            PA_91,
            PA_92,
            PA_93,
            PA_94,
            PA_95,
            PA_96,
            PA_97,
            PA_98,
            PA_99,
            PA_100,
            PA_101,
            PA_102,
            PA_103,
            PA_104,
            PA_105,
            PA_106,
            PA_107,
            PA_108,
            PA_109,
            PA_110,
            PA_111,
            PA_112,
            PA_113,
            PA_114,
            PA_115,
            PA_116,
            PA_117,
            PA_118,
            PA_119,
            PA_120,
            PA_121,
            PA_122,
            PA_123,
            PA_124,
            PA_125,
            PA_126,
            PA_127,
            PA_128,
            PA_129,
            PA_130,
            PA_131,
            PA_132,
            PA_133,
            PA_134,
            PA_135,
            PA_136,
            PA_137,
            PA_138,
            PA_139,
            PA_140,
            PA_141,
            PA_142,
            PA_143,
            PA_144,
            PA_145,
            PA_146,
            PA_147,
            PA_148,
            PA_149,
            PA_150,
            PA_151,
            PA_152,
            PA_153,
            PA_154,
            PA_155,
            PA_156,
            PA_157,
            PA_158,
            PA_159,
            PA_160,
            PA_161,
            PA_162,
            PA_163,
            PA_164,
            PA_165,
            PA_166,
            PA_167,
            PA_168,
            PA_169,
            PA_170,
            PA_171,
            PA_172,
            PA_173,
            PA_174,
            PA_175,
            PA_176,
            PA_177,
            PA_178,
            PA_179,
            PA_180,
            PA_181,
            PA_182,
            PA_183,
            PA_184,
            PA_185,
            PA_186,
            PA_187,
            PA_188,
            PA_189,
            PA_190,
            PA_191,
            PA_192,
            PA_193,
            PA_194,
            PA_195,
            PA_196,
            PA_197,
            PA_198,
            PA_199,
            PA_200,
            PA_201,
            PA_202,
            PA_203,
            PA_204,
            PA_205,
            PA_206,
            PA_207,
            PA_208,
            PA_209,
            PA_210,
            PA_211,
            PA_212,
            PA_213,
            PA_214,
            PA_215,
            PA_216,
            PA_217,
            PA_218,
            PA_219,
            PA_220,
            PA_221,
            PA_222,
            PA_223,
            PA_224,
            PA_225,
            PA_226,
            PA_227,
            PA_228,
            PA_229,
            PA_230,
            PA_231,
            PA_232,
            PA_233,
            PA_234,
            PA_235,
            PA_236,
            PA_237,
            PA_238,
            PA_239,
            PA_240,
            PA_241,
            PA_242,
            PA_243,
            PA_244,
            PA_245,
            PA_246,
            PA_247,
            PA_248,
            PA_249,
            PA_250,
            PA_251,
            PA_252,
            PA_253,
            PA_254,
            PA_255,
            PA_256,
            MONTO,
			NumeroRenglon
        )
        SELECT IdDetalle,
               IdActividadPetrolera,
               ActividadPetrolera,
               IdSubactividadPetrolera,
               SubactividadPetrolera,
               IdTarea,
               Tarea,
               IdSubtarea,
               Subtarea_Servicio,
               Elegible,
               Area,
               Campo,
               Yacimiento,
               Pozo_Instalacion,
               CAPEX_OPEX,
               PA_17,
               PA_18,
               PA_19,
               PA_20,
               PA_21,
               PA_22,
               PA_23,
               PA_24,
               PA_25,
               PA_26,
               PA_27,
               PA_28,
               PA_29,
               PA_30,
               PA_31,
               PA_32,
               PA_33,
               PA_34,
               PA_35,
               PA_36,
               PA_37,
               PA_38,
               PA_39,
               PA_40,
               PA_41,
               PA_42,
               PA_43,
               PA_44,
               PA_45,
               PA_46,
               PA_47,
               PA_48,
               PA_49,
               PA_50,
               PA_51,
               PA_52,
               PA_53,
               PA_54,
               PA_55,
               PA_56,
               PA_57,
               PA_58,
               PA_59,
               PA_60,
               PA_61,
               PA_62,
               PA_63,
               PA_64,
               PA_65,
               PA_66,
               PA_67,
               PA_68,
               PA_69,
               PA_70,
               PA_71,
               PA_72,
               PA_73,
               PA_74,
               PA_75,
               PA_76,
               PA_77,
               PA_78,
               PA_79,
               PA_80,
               PA_81,
               PA_82,
               PA_83,
               PA_84,
               PA_85,
               PA_86,
               PA_87,
               PA_88,
               PA_89,
               PA_90,
               PA_91,
               PA_92,
               PA_93,
               PA_94,
               PA_95,
               PA_96,
               PA_97,
               PA_98,
               PA_99,
               PA_100,
               PA_101,
               PA_102,
               PA_103,
               PA_104,
               PA_105,
               PA_106,
               PA_107,
               PA_108,
               PA_109,
               PA_110,
               PA_111,
               PA_112,
               PA_113,
               PA_114,
               PA_115,
               PA_116,
               PA_117,
               PA_118,
               PA_119,
               PA_120,
               PA_121,
               PA_122,
               PA_123,
               PA_124,
               PA_125,
               PA_126,
               PA_127,
               PA_128,
               PA_129,
               PA_130,
               PA_131,
               PA_132,
               PA_133,
               PA_134,
               PA_135,
               PA_136,
               PA_137,
               PA_138,
        PA_139,
               PA_140,
               PA_141,
               PA_142,
               PA_143,
               PA_144,
               PA_145,
               PA_146,
               PA_147,
               PA_148,
               PA_149,
               PA_150,
               PA_151,
               PA_152,
               PA_153,
               PA_154,
               PA_155,
               PA_156,
               PA_157,
               PA_158,
               PA_159,
               PA_160,
               PA_161,
               PA_162,
               PA_163,
               PA_164,
               PA_165,
               PA_166,
               PA_167,
               PA_168,
               PA_169,
               PA_170,
               PA_171,
               PA_172,
               PA_173,
               PA_174,
               PA_175,
               PA_176,
               PA_177,
               PA_178,
               PA_179,
               PA_180,
               PA_181,
               PA_182,
               PA_183,
               PA_184,
               PA_185,
               PA_186,
               PA_187,
               PA_188,
               PA_189,
               PA_190,
               PA_191,
               PA_192,
               PA_193,
               PA_194,
               PA_195,
               PA_196,
               PA_197,
               PA_198,
               PA_199,
               PA_200,
               PA_201,
               PA_202,
               PA_203,
               PA_204,
               PA_205,
               PA_206,
               PA_207,
               PA_208,
               PA_209,
               PA_210,
               PA_211,
               PA_212,
               PA_213,
               PA_214,
               PA_215,
               PA_216,
               PA_217,
               PA_218,
               PA_219,
               PA_220,
               PA_221,
               PA_222,
               PA_223,
               PA_224,
               PA_225,
               PA_226,
               PA_227,
               PA_228,
               PA_229,
               PA_230,
               PA_231,
               PA_232,
               PA_233,
               PA_234,
               PA_235,
               PA_236,
               PA_237,
               PA_238,
               PA_239,
               PA_240,
               PA_241,
               PA_242,
               PA_243,
               PA_244,
               PA_245,
               PA_246,
               PA_247,
               PA_248,
               PA_249,
               PA_250,
               PA_251,
               PA_252,
               PA_253,
               PA_254,
               PA_255,
               PA_256,
               ISNULL(PA_17, 0) + ISNULL(PA_18, 0) + ISNULL(PA_19, 0) + ISNULL(PA_20, 0) + ISNULL(PA_21, 0)
               + ISNULL(PA_22, 0) + ISNULL(PA_23, 0) + ISNULL(PA_24, 0) + ISNULL(PA_25, 0) + ISNULL(PA_26, 0)
               + ISNULL(PA_27, 0) + ISNULL(PA_28, 0) + ISNULL(PA_29, 0) + ISNULL(PA_30, 0) + ISNULL(PA_31, 0)
               + ISNULL(PA_32, 0) + ISNULL(PA_33, 0) + ISNULL(PA_34, 0) + ISNULL(PA_35, 0) + ISNULL(PA_36, 0)
               + ISNULL(PA_37, 0) + ISNULL(PA_38, 0) + ISNULL(PA_39, 0) + ISNULL(PA_40, 0) + ISNULL(PA_41, 0)
               + ISNULL(PA_42, 0) + ISNULL(PA_43, 0) + ISNULL(PA_44, 0) + ISNULL(PA_45, 0) + ISNULL(PA_46, 0)
               + ISNULL(PA_47, 0) + ISNULL(PA_48, 0) + ISNULL(PA_49, 0) + ISNULL(PA_50, 0) + ISNULL(PA_51, 0)
               + ISNULL(PA_52, 0) + ISNULL(PA_53, 0) + ISNULL(PA_54, 0) + ISNULL(PA_55, 0) + ISNULL(PA_56, 0)
               + ISNULL(PA_57, 0) + ISNULL(PA_58, 0) + ISNULL(PA_59, 0) + ISNULL(PA_60, 0) + ISNULL(PA_61, 0)
               + ISNULL(PA_62, 0) + ISNULL(PA_63, 0) + ISNULL(PA_64, 0) + ISNULL(PA_65, 0) + ISNULL(PA_66, 0)
               + ISNULL(PA_67, 0) + ISNULL(PA_68, 0) + ISNULL(PA_69, 0) + ISNULL(PA_70, 0) + ISNULL(PA_71, 0)
               + ISNULL(PA_72, 0) + ISNULL(PA_73, 0) + ISNULL(PA_74, 0) + ISNULL(PA_75, 0) + ISNULL(PA_76, 0)
               + ISNULL(PA_77, 0) + ISNULL(PA_78, 0) + ISNULL(PA_79, 0) + ISNULL(PA_80, 0) + ISNULL(PA_81, 0)
               + ISNULL(PA_82, 0) + ISNULL(PA_83, 0) + ISNULL(PA_84, 0) + ISNULL(PA_85, 0) + ISNULL(PA_86, 0)
               + ISNULL(PA_87, 0) + ISNULL(PA_88, 0) + ISNULL(PA_89, 0) + ISNULL(PA_90, 0) + ISNULL(PA_91, 0)
               + ISNULL(PA_92, 0) + ISNULL(PA_93, 0) + ISNULL(PA_94, 0) + ISNULL(PA_95, 0) + ISNULL(PA_96, 0)
               + ISNULL(PA_97, 0) + ISNULL(PA_98, 0) + ISNULL(PA_99, 0) + ISNULL(PA_100, 0) + ISNULL(PA_101, 0)
               + ISNULL(PA_102, 0) + ISNULL(PA_103, 0) + ISNULL(PA_104, 0) + ISNULL(PA_105, 0) + ISNULL(PA_106, 0)
               + ISNULL(PA_107, 0) + ISNULL(PA_108, 0) + ISNULL(PA_109, 0) + ISNULL(PA_110, 0) + ISNULL(PA_111, 0)
               + ISNULL(PA_112, 0) + ISNULL(PA_113, 0) + ISNULL(PA_114, 0) + ISNULL(PA_115, 0) + ISNULL(PA_116, 0)
               + ISNULL(PA_117, 0) + ISNULL(PA_118, 0) + ISNULL(PA_119, 0) + ISNULL(PA_120, 0) + ISNULL(PA_121, 0)
               + ISNULL(PA_122, 0) + ISNULL(PA_123, 0) + ISNULL(PA_124, 0) + ISNULL(PA_125, 0) + ISNULL(PA_126, 0)
               + ISNULL(PA_127, 0) + ISNULL(PA_128, 0) + ISNULL(PA_129, 0) + ISNULL(PA_130, 0) + ISNULL(PA_131, 0)
               + ISNULL(PA_132, 0) + ISNULL(PA_133, 0) + ISNULL(PA_134, 0) + ISNULL(PA_135, 0) + ISNULL(PA_136, 0)
               + ISNULL(PA_137, 0) + ISNULL(PA_138, 0) + ISNULL(PA_139, 0) + ISNULL(PA_140, 0) + ISNULL(PA_141, 0)
               + ISNULL(PA_142, 0) + ISNULL(PA_143, 0) + ISNULL(PA_144, 0) + ISNULL(PA_145, 0) + ISNULL(PA_146, 0)
               + ISNULL(PA_147, 0) + ISNULL(PA_148, 0) + ISNULL(PA_149, 0) + ISNULL(PA_150, 0) + ISNULL(PA_151, 0)
               + ISNULL(PA_152, 0) + ISNULL(PA_153, 0) + ISNULL(PA_154, 0) + ISNULL(PA_155, 0) + ISNULL(PA_156, 0)
               + ISNULL(PA_157, 0) + ISNULL(PA_158, 0) + ISNULL(PA_159, 0) + ISNULL(PA_160, 0) + ISNULL(PA_161, 0)
               + ISNULL(PA_162, 0) + ISNULL(PA_163, 0) + ISNULL(PA_164, 0) + ISNULL(PA_165, 0) + ISNULL(PA_166, 0)
               + ISNULL(PA_167, 0) + ISNULL(PA_168, 0) + ISNULL(PA_169, 0) + ISNULL(PA_170, 0) + ISNULL(PA_171, 0)
               + ISNULL(PA_172, 0) + ISNULL(PA_173, 0) + ISNULL(PA_174, 0) + ISNULL(PA_175, 0) + ISNULL(PA_176, 0)
               + ISNULL(PA_177, 0) + ISNULL(PA_178, 0) + ISNULL(PA_179, 0) + ISNULL(PA_180, 0) + ISNULL(PA_181, 0)
               + ISNULL(PA_182, 0) + ISNULL(PA_183, 0) + ISNULL(PA_184, 0) + ISNULL(PA_185, 0) + ISNULL(PA_186, 0)
               + ISNULL(PA_187, 0) + ISNULL(PA_188, 0) + ISNULL(PA_189, 0) + ISNULL(PA_190, 0) + ISNULL(PA_191, 0)
               + ISNULL(PA_192, 0) + ISNULL(PA_193, 0) + ISNULL(PA_194, 0) + ISNULL(PA_195, 0) + ISNULL(PA_196, 0)
               + ISNULL(PA_197, 0) + ISNULL(PA_198, 0) + ISNULL(PA_199, 0) + ISNULL(PA_200, 0) + ISNULL(PA_201, 0)
               + ISNULL(PA_202, 0) + ISNULL(PA_203, 0) + ISNULL(PA_204, 0) + ISNULL(PA_205, 0) + ISNULL(PA_206, 0)
               + ISNULL(PA_207, 0) + ISNULL(PA_208, 0) + ISNULL(PA_209, 0) + ISNULL(PA_210, 0) + ISNULL(PA_211, 0)
               + ISNULL(PA_212, 0) + ISNULL(PA_213, 0) + ISNULL(PA_214, 0) + ISNULL(PA_215, 0) + ISNULL(PA_216, 0)
               + ISNULL(PA_217, 0) + ISNULL(PA_218, 0) + ISNULL(PA_219, 0) + ISNULL(PA_220, 0) + ISNULL(PA_221, 0)
               + ISNULL(PA_222, 0) + ISNULL(PA_223, 0) + ISNULL(PA_224, 0) + ISNULL(PA_225, 0) + ISNULL(PA_226, 0)
               + ISNULL(PA_227, 0) + ISNULL(PA_228, 0) + ISNULL(PA_229, 0) + ISNULL(PA_230, 0) + ISNULL(PA_231, 0)
               + ISNULL(PA_232, 0) + ISNULL(PA_233, 0) + ISNULL(PA_234, 0) + ISNULL(PA_235, 0) + ISNULL(PA_236, 0)
               + ISNULL(PA_237, 0) + ISNULL(PA_238, 0) + ISNULL(PA_239, 0) + ISNULL(PA_240, 0) + ISNULL(PA_241, 0)
               + ISNULL(PA_242, 0) + ISNULL(PA_243, 0) + ISNULL(PA_244, 0) + ISNULL(PA_245, 0) + ISNULL(PA_246, 0)
               + ISNULL(PA_247, 0) + ISNULL(PA_248, 0) + ISNULL(PA_249, 0) + ISNULL(PA_250, 0) + ISNULL(PA_251, 0)
               + ISNULL(PA_252, 0) + ISNULL(PA_253, 0) + ISNULL(PA_254, 0) + ISNULL(PA_255, 0) + ISNULL(PA_256, 0),
			   NumeroRenglon
        FROM @Table_CO_Type_BitacoraPresupuestoDetalle;

        IF (@AdjuntarClaveSubtarea = 1)
        BEGIN
            INSERT INTO #TablaTemporalValidacionServicio
            (
                IdSubtarea,
                Subtarea_Servicio,
                Existe,
                Activo,
                NumeroRepetidas
            )
            SELECT IdSubtarea,
                   Subtarea_Servicio,
                   0,
                   0,
                   COUNT(Subtarea_Servicio)
            FROM CO_BitacoraPresupuestoDetalle (NOLOCK)
            WHERE IdCarga = @IdCarga
            GROUP BY IdSubtarea,
                     Subtarea_Servicio
        END
        ELSE
        BEGIN
            INSERT INTO #TablaTemporalValidacionServicio
            (
                IdSubtarea,
                Subtarea_Servicio,
                Existe,
                Activo,
                NumeroRepetidas
            )
            SELECT '',
                   Subtarea_Servicio,
                   0,
                   0,
                   COUNT(Subtarea_Servicio)
            FROM CO_BitacoraPresupuestoDetalle (NOLOCK)
            WHERE IdCarga = @IdCarga
            GROUP BY Subtarea_Servicio
        END

        INSERT INTO #TablaTemporalValidacionInstalacion
        (
 Pozo_Instalacion,
            Existe,
            Activo,
            NumeroRepetidas
        )
        SELECT Pozo_Instalacion,
               0,
               0,
               COUNT(Pozo_Instalacion)
        FROM CO_BitacoraPresupuestoDetalle (NOLOCK)
        WHERE IdCarga = @IdCarga
        GROUP BY Pozo_Instalacion

        /*=========================*/
        /*Verificacion de Servicios*/
        /*=========================*/
        IF (@AdjuntarClaveSubtarea = 1)
        BEGIN
            UPDATE #TablaTemporalValidacionServicio
            SET #TablaTemporalValidacionServicio.Activo = ISNULL(CO_Servicio.Activo, 0),
                #TablaTemporalValidacionServicio.Existe = 1
            FROM #TablaTemporalValidacionServicio
                JOIN CO_Servicio
                    ON LTRIM(RTRIM(CONCAT(
                                             #TablaTemporalValidacionServicio.IdSubtarea,
                                             '-',
                                             #TablaTemporalValidacionServicio.Subtarea_Servicio
                                         )
                                  )
                            ) = LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, '')))
            WHERE CO_Servicio.IdContrato = @IdContratoSeleccionado

            INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         #TablaTemporalValidacionServicio.IdSubtarea,
                                         '-',
                                         #TablaTemporalValidacionServicio.Subtarea_Servicio,
                                         ' (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
                                         ') [NO ACTIVO]'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE Activo = 0
                  AND Existe = 1
                  AND Subtarea_Servicio <> ''

            INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         #TablaTemporalValidacionServicio.IdSubtarea,
                                         '-',
                                         #TablaTemporalValidacionServicio.Subtarea_Servicio,
                                         ' (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
                                         ')'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE Existe = 0
                  AND Subtarea_Servicio <> ''
        END
        ELSE
        BEGIN
            UPDATE #TablaTemporalValidacionServicio
            SET #TablaTemporalValidacionServicio.Activo = ISNULL(CO_Servicio.Activo, 0),
                #TablaTemporalValidacionServicio.Existe = 1
            FROM #TablaTemporalValidacionServicio
                JOIN CO_Servicio
                    ON LTRIM(RTRIM(#TablaTemporalValidacionServicio.Subtarea_Servicio)) = LTRIM(RTRIM(ISNULL(
                                                                                                                CO_Servicio.NombreServicio,
                                                                                                                ''
                                                                                                            )
                                             )
                                                                                        )
            WHERE CO_Servicio.IdContrato = @IdContratoSeleccionado

            INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         #TablaTemporalValidacionServicio.Subtarea_Servicio,
                                         ' (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
                                         ') [NO ACTIVO]'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE Activo = 0
                  AND Existe = 1
                  AND Subtarea_Servicio <> ''

            INSERT INTO #TablaTemporalValidacionDetalles
            (
                Tipo,
                Descripcion
            )
            SELECT 'ALERTA_SERVICIO',
                   LTRIM(RTRIM(CONCAT(
                                         #TablaTemporalValidacionServicio.Subtarea_Servicio,
                                         ' (',
                                         CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
                                         ')'
                                     )
                              )
                        )
            FROM #TablaTemporalValidacionServicio
            WHERE Existe = 0
                  AND Subtarea_Servicio <> ''
        END

        INSERT INTO #TablaTemporalValidacionDetalles
        (
            Tipo,
            Descripcion
        )
        SELECT 'ALERTA_SERVICIO',
               LTRIM(RTRIM(CONCAT(
                                     'Se encontraron un total de (',
                                     CONVERT(VARCHAR(10), #TablaTemporalValidacionServicio.NumeroRepetidas),
                                     ') filas con servicios vacíos'
                                 )
                          )
                    )
        FROM #TablaTemporalValidacionServicio
        WHERE ISNULL(Subtarea_Servicio, '') = ''

        UPDATE #TablaTemporalValidacionInstalacion
        SET #TablaTemporalValidacionInstalacion.Activo = ISNULL(CO_Instalacion.Activo, 0),
            #TablaTemporalValidacionInstalacion.Existe = 1
        FROM #TablaTemporalValidacionInstalacion
            JOIN CO_Instalacion
                ON LTRIM(RTRIM(#TablaTemporalValidacionInstalacion.Pozo_Instalacion)) = LTRIM(RTRIM(ISNULL(
                                                                                                              CO_Instalacion.NombreInstalacion,
                                                                                                              ''
                                                                                                          )
                                                                                                   )
                                                                                             )
        WHERE CO_Instalacion.IdAreaContractual = @IdAreaContractual

        /*=============================*/
        /*Verificacion de Instalaciones*/
        /*=============================*/
        INSERT INTO #TablaTemporalValidacionDetalles
        (
            Tipo,
            Descripcion
        )
        SELECT 'ALERTA_INSTALACION',
               LTRIM(RTRIM(CONCAT(
                                     #TablaTemporalValidacionInstalacion.Pozo_Instalacion,
                                     ' (',
                                     CONVERT(VARCHAR(10), #TablaTemporalValidacionInstalacion.NumeroRepetidas),
                                     ') [NO ACTIVO]'
                                 )
                          )
                    )
        FROM #TablaTemporalValidacionInstalacion
        WHERE Activo = 0
              AND Existe = 1
              AND Pozo_Instalacion <> ''

        INSERT INTO #TablaTemporalValidacionDetalles
        (
            Tipo,
            Descripcion
        )
        SELECT 'ALERTA_INSTALACION',
               LTRIM(RTRIM(CONCAT(
                                     #TablaTemporalValidacionInstalacion.Pozo_Instalacion,
                                     ' (',
                                     CONVERT(VARCHAR(10), #TablaTemporalValidacionInstalacion.NumeroRepetidas),
                                     ')'
                                 )
                          )
                    )
        FROM #TablaTemporalValidacionInstalacion
        WHERE Existe = 0
              AND Pozo_Instalacion <> ''

        INSERT INTO #TablaTemporalValidacionDetalles
        (
            Tipo,
            Descripcion
        )
        SELECT 'ALERTA_INSTALACION',
               LTRIM(RTRIM(CONCAT(
                                     'Se encontraron un total de  (',
                                     CONVERT(VARCHAR(10), #TablaTemporalValidacionInstalacion.NumeroRepetidas),
                                     ') filas con instalaciones vacías'
                                 )
                          )
                    )
        FROM #TablaTemporalValidacionInstalacion
        WHERE ISNULL(Pozo_Instalacion, '') = '';

        /*======================================*/
        /*Verificacion de Id Actividad Petrolera*/
        /*======================================*/
        IF (
           (
               SELECT COUNT(1)
               FROM #TablaTemporalBitacoraPresupuestoDetalle
               WHERE ISNULL(IdActividadPetrolera, '') = ''
           ) > 0
           )
        BEGIN
            IF (
               (
                   SELECT COUNT(1)
                   FROM #TablaTemporalBitacoraPresupuestoDetalle
                   WHERE ISNULL(IdActividadPetrolera, '') = ''
               ) = 1
               )
            BEGIN
                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                SELECT 'ALERTA_DATOSGENERALES',
                       CONCAT('Renglón: ', CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)),
                       'IdActividadPetrolera',
                       0,
                       1
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(IdActividadPetrolera, '') = ''
                ORDER BY IdDetalle ASC
            END
            ELSE
            BEGIN
                SELECT @DetalleAnalisisDatosGenerales
                    = CONCAT(
                                'Renglones: ',
                                STUFF(
                                (
                                    SELECT ', '
                                           + CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)
                                    FROM #TablaTemporalBitacoraPresupuestoDetalle
                                    WHERE ISNULL(IdActividadPetrolera, '') = ''
                                    ORDER BY IdDetalle ASC
                                    FOR XML PATH('')
                                ),
                                1,
                                2,
                                ''
                                     )
                            )
                SELECT @NumeroAlertasDatosGenerales = COUNT(1)
                FROM #TablaTemporalBitacoraPresupuestoDetalle
       WHERE ISNULL(IdActividadPetrolera, '') = ''

                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                VALUES
                ('ALERTA_DATOSGENERALES',
                 @DetalleAnalisisDatosGenerales,
                 'IdActividadPetrolera',
                 1  ,
                 @NumeroAlertasDatosGenerales
                )

                SET @DetalleAnalisisDatosGenerales = '';
                SET @NumeroAlertasDatosGenerales = 0;
            END
        END
        /*===================================*/
        /*Verificacion de Actividad Petrolera*/
        /*===================================*/
        IF (
           (
               SELECT COUNT(1)
               FROM #TablaTemporalBitacoraPresupuestoDetalle
               WHERE ISNULL(ActividadPetrolera, '') = ''
           ) > 0
           )
        BEGIN
            IF (
               (
                   SELECT COUNT(1)
                   FROM #TablaTemporalBitacoraPresupuestoDetalle
                   WHERE ISNULL(ActividadPetrolera, '') = ''
               ) = 1
               )
            BEGIN
                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                SELECT 'ALERTA_DATOSGENERALES',
                       CONCAT('Renglón: ', CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)),
                       'ActividadPetrolera',
                       0,
                       1
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(ActividadPetrolera, '') = ''
                ORDER BY IdDetalle ASC
            END
            ELSE
            BEGIN
                SELECT @DetalleAnalisisDatosGenerales
                    = CONCAT(
                                'Renglones: ',
                                STUFF(
                                (
                                    SELECT ', '
                                           + CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)
                                    FROM #TablaTemporalBitacoraPresupuestoDetalle
                                    WHERE ISNULL(ActividadPetrolera, '') = ''
                                    ORDER BY IdDetalle ASC
                                    FOR XML PATH('')
                                ),
                                1,
                                2,
                                ''
                                     )
                            )

                SELECT @NumeroAlertasDatosGenerales = COUNT(1)
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(ActividadPetrolera, '') = ''

                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                VALUES
                ('ALERTA_DATOSGENERALES',
                 @DetalleAnalisisDatosGenerales,
                 'ActividadPetrolera',
                 1  ,
                 @NumeroAlertasDatosGenerales
                )

                SET @DetalleAnalisisDatosGenerales = '';
                SET @NumeroAlertasDatosGenerales = 0;
            END
        END
        /*=========================================*/
        /*Verificacion de Id Subactividad Petrolera*/
        /*=========================================*/
        IF (
           (
               SELECT COUNT(1)
               FROM #TablaTemporalBitacoraPresupuestoDetalle
               WHERE ISNULL(IdSubactividadPetrolera, '') = ''
           ) > 0
           )
        BEGIN
            IF (
               (
                   SELECT COUNT(1)
                   FROM #TablaTemporalBitacoraPresupuestoDetalle
                   WHERE ISNULL(IdSubactividadPetrolera, '') = ''
               ) = 1
               )
            BEGIN
                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                SELECT 'ALERTA_DATOSGENERALES',
                       CONCAT('Renglón: ', CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)),
                       'IdSubactividadPetrolera',
                       0,
                       1
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(IdSubactividadPetrolera, '') = ''
                ORDER BY IdDetalle ASC
            END
            ELSE
            BEGIN
                SELECT @DetalleAnalisisDatosGenerales
                    = CONCAT(
                                'Renglones: ',
                                STUFF(
                                (
                                    SELECT ', '
                                           + CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)
                                    FROM #TablaTemporalBitacoraPresupuestoDetalle
                                    WHERE ISNULL(IdSubactividadPetrolera, '') = ''
                                    ORDER BY IdDetalle ASC
                                    FOR XML PATH('')
                                ),
                                1,
                                2,
                                ''
                                     )
                            )

                SELECT @NumeroAlertasDatosGenerales = COUNT(1)
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(IdSubactividadPetrolera, '') = ''

                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                VALUES
                ('ALERTA_DATOSGENERALES',
                 @DetalleAnalisisDatosGenerales,
                 'IdSubactividadPetrolera',
                 1  ,
                 @NumeroAlertasDatosGenerales
                )

                SET @DetalleAnalisisDatosGenerales = '';
                SET @NumeroAlertasDatosGenerales = 0;
            END
        END
        /*======================================*/
        /*Verificacion de Subactividad Petrolera*/
        /*======================================*/
        IF (
           (
               SELECT COUNT(1)
               FROM #TablaTemporalBitacoraPresupuestoDetalle
               WHERE ISNULL(SubactividadPetrolera, '') = ''
           ) > 0
           )
        BEGIN
            IF (
               (
                   SELECT COUNT(1)
                   FROM #TablaTemporalBitacoraPresupuestoDetalle
                   WHERE ISNULL(SubactividadPetrolera, '') = ''
               ) = 1
               )
            BEGIN
                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                SELECT 'ALERTA_DATOSGENERALES',
    CONCAT('Renglón: ', CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)),
                       'SubactividadPetrolera',
                       0,
                       1
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(SubactividadPetrolera, '') = ''
                ORDER BY IdDetalle ASC
            END
            ELSE
            BEGIN
                SELECT @DetalleAnalisisDatosGenerales
                    = CONCAT(
                                'Renglones: ',
                                STUFF(
                                (
                                    SELECT ', '
                                           + CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)
                                    FROM #TablaTemporalBitacoraPresupuestoDetalle
                                    WHERE ISNULL(SubactividadPetrolera, '') = ''
                                    ORDER BY IdDetalle ASC
                                    FOR XML PATH('')
                                ),
                                1,
                                2,
                                ''
                                     )
                            )

                SELECT @NumeroAlertasDatosGenerales = COUNT(1)
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(SubactividadPetrolera, '') = ''

                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                VALUES
                ('ALERTA_DATOSGENERALES',
                 @DetalleAnalisisDatosGenerales,
                 'SubactividadPetrolera',
                 1  ,
                 @NumeroAlertasDatosGenerales
                )

                SET @DetalleAnalisisDatosGenerales = '';
                SET @NumeroAlertasDatosGenerales = 0;
            END
        END
        /*========================*/
        /*Verificacion de Id Tarea*/
        /*========================*/
        IF (
           (
               SELECT COUNT(1)
               FROM #TablaTemporalBitacoraPresupuestoDetalle
               WHERE ISNULL(IdTarea, '') = ''
           ) > 0
           )
        BEGIN
            IF (
               (
                   SELECT COUNT(1)
                   FROM #TablaTemporalBitacoraPresupuestoDetalle
                   WHERE ISNULL(IdTarea, '') = ''
               ) = 1
               )
            BEGIN
                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                SELECT 'ALERTA_DATOSGENERALES',
                       CONCAT('Renglón: ', CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)),
                       'IdTarea',
                       0,
                       1
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(IdTarea, '') = ''
                ORDER BY IdDetalle ASC
            END
            ELSE
            BEGIN
                SELECT @DetalleAnalisisDatosGenerales
                    = CONCAT(
                                'Renglones: ',
                                STUFF(
                                (
                                    SELECT ', '
                                           + CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)
                                    FROM #TablaTemporalBitacoraPresupuestoDetalle
                                    WHERE ISNULL(IdTarea, '') = ''
                                    ORDER BY IdDetalle ASC
                                    FOR XML PATH('')
                                ),
                                1,
                                2,
                                ''
                                     )
                            )

                SELECT @NumeroAlertasDatosGenerales = COUNT(1)
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(IdTarea, '') = ''

                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                VALUES
                ('ALERTA_DATOSGENERALES', @DetalleAnalisisDatosGenerales, 'IdTarea', 1, @NumeroAlertasDatosGenerales)

                SET @DetalleAnalisisDatosGenerales = '';
                SET @NumeroAlertasDatosGenerales = 0;
            END
        END
        /*=====================*/
        /*Verificacion de Tarea*/
        /*=====================*/
        IF (
           (
               SELECT COUNT(1)
               FROM #TablaTemporalBitacoraPresupuestoDetalle
               WHERE ISNULL(Tarea, '') = ''
           ) > 0
           )
        BEGIN
            IF (
               (
                   SELECT COUNT(1)
                   FROM #TablaTemporalBitacoraPresupuestoDetalle
                   WHERE ISNULL(Tarea, '') = ''
               ) = 1
               )
            BEGIN
                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                SELECT 'ALERTA_DATOSGENERALES',
                       CONCAT('Renglón: ', CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)),
                       'Tarea',
                       0,
                       1
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(Tarea, '') = ''
                ORDER BY IdDetalle ASC
            END
            ELSE
            BEGIN
                SELECT @DetalleAnalisisDatosGenerales
                    = CONCAT(
                                'Renglones: ',
                                STUFF(
                                (
                                    SELECT ', '
                                           + CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)
                                    FROM #TablaTemporalBitacoraPresupuestoDetalle
                                    WHERE ISNULL(Tarea, '') = ''
                                    ORDER BY IdDetalle ASC
                                    FOR XML PATH('')
                                ),
                                1,
                                2,
                                ''
                                     )
                            )

                SELECT @NumeroAlertasDatosGenerales = COUNT(1)
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(Tarea, '') = ''

                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                VALUES
                ('ALERTA_DATOSGENERALES', @DetalleAnalisisDatosGenerales, 'Tarea', 1, @NumeroAlertasDatosGenerales)

                SET @DetalleAnalisisDatosGenerales = '';
                SET @NumeroAlertasDatosGenerales = 0;
            END
        END
        /*===========================*/
        /*Verificacion de Monto = 0*/
        /*===========================*/
        IF (
           (
               SELECT COUNT(1)
               FROM #TablaTemporalBitacoraPresupuestoDetalle
               WHERE ISNULL(MONTO, 0) = 0
           ) > 0
           )
        BEGIN
            IF (
               (
                   SELECT COUNT(1)
                   FROM #TablaTemporalBitacoraPresupuestoDetalle
                   WHERE ISNULL(MONTO, 0) = 0
               ) = 1
               )
            BEGIN
                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                SELECT 'ALERTA_DATOSGENERALES',
                       CONCAT('Renglón: ', CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)),
                       'MONTO',
                       0,
                       1
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(MONTO, 0) = 0
                ORDER BY IdDetalle ASC
            END
            ELSE
            BEGIN
                SELECT @DetalleAnalisisDatosGenerales
                    = CONCAT(
                                'Renglones: ',
                                STUFF(
                                (
                                    SELECT ', '
                                           + CONVERT(VARCHAR(10), #TablaTemporalBitacoraPresupuestoDetalle.NumeroRenglon)
                                    FROM #TablaTemporalBitacoraPresupuestoDetalle
                                    WHERE ISNULL(MONTO, 0) = 0
                                    ORDER BY IdDetalle ASC
                                    FOR XML PATH('')
                                ),
                                1,
                                2,
                                ''
                                     )
                            )

                SELECT @NumeroAlertasDatosGenerales = COUNT(1)
                FROM #TablaTemporalBitacoraPresupuestoDetalle
                WHERE ISNULL(MONTO, 0) = 0

                INSERT INTO #TablaTemporalValidacionDetalles
                (
                    Tipo,
                    Descripcion,
                    TipoDetalle,
                    MultiplesDetalles,
                    NumeroDeDetalles
                )
                VALUES
                ('ALERTA_DATOSGENERALES', @DetalleAnalisisDatosGenerales, 'MONTO', 1, @NumeroAlertasDatosGenerales)

                SET @DetalleAnalisisDatosGenerales = '';
                SET @NumeroAlertasDatosGenerales = 0;
            END
        END

        SELECT @NumeroAlertasServicio = COUNT(1)
        FROM #TablaTemporalValidacionDetalles
        WHERE Tipo = 'ALERTA_SERVICIO'

        SELECT @NumeroAlertasInstalacion = COUNT(1)
        FROM #TablaTemporalValidacionDetalles
        WHERE Tipo = 'ALERTA_INSTALACION'

        SELECT @NumeroAlertasDatosGenerales = COUNT(1)
        FROM #TablaTemporalValidacionDetalles
        WHERE Tipo = 'ALERTA_DATOSGENERALES'

        IF (
               @NumeroAlertasServicio > 0
               AND @NumeroAlertasInstalacion > 0
               AND @NumeroAlertasDatosGenerales > 0
           )
            SELECT @Mensaje = 'ALERTA_SERVICIO_INSTALACION_DATOSGENERALES'

        IF (
               @NumeroAlertasServicio > 0
               AND @NumeroAlertasInstalacion > 0
               AND @NumeroAlertasDatosGenerales = 0
           )
            SELECT @Mensaje = 'ALERTA_SERVICIO_INSTALACION'

        IF (
               @NumeroAlertasServicio > 0
               AND @NumeroAlertasInstalacion = 0
               AND @NumeroAlertasDatosGenerales > 0
           )
   SELECT @Mensaje = 'ALERTA_SERVICIO_DATOSGENERALES'

        IF (
               @NumeroAlertasServicio = 0
               AND @NumeroAlertasInstalacion > 0
               AND @NumeroAlertasDatosGenerales > 0
           )
            SELECT @Mensaje = 'ALERTA_INSTALACION_DATOSGENERALES'

        IF (
               @NumeroAlertasServicio > 0
               AND @NumeroAlertasInstalacion = 0
               AND @NumeroAlertasDatosGenerales = 0
           )
            SELECT @Mensaje = 'ALERTA_SERVICIO'

        IF (
               @NumeroAlertasServicio = 0
               AND @NumeroAlertasInstalacion > 0
               AND @NumeroAlertasDatosGenerales = 0
           )
            SELECT @Mensaje = 'ALERTA_INSTALACION'

        IF (
               @NumeroAlertasServicio = 0
               AND @NumeroAlertasInstalacion = 0
               AND @NumeroAlertasDatosGenerales > 0
           )
            SELECT @Mensaje = 'ALERTA_DATOSGENERALES'

        IF (
               @NumeroAlertasServicio = 0
               AND @NumeroAlertasInstalacion = 0
               AND @NumeroAlertasDatosGenerales = 0
           )
            SELECT @Mensaje = 'VALIDACION_EXITOSA'

        SELECT @Mensaje AS MENSAJE

        IF (@Mensaje <> 'VALIDACION_EXITOSA')
        BEGIN
            SELECT Descripcion
            FROM #TablaTemporalValidacionDetalles
            WHERE Tipo = 'ALERTA_SERVICIO'

            SELECT Descripcion
            FROM #TablaTemporalValidacionDetalles
            WHERE Tipo = 'ALERTA_INSTALACION'

            SELECT Descripcion,
                   TipoDetalle,
                   NumeroDeDetalles
            FROM #TablaTemporalValidacionDetalles
            WHERE Tipo = 'ALERTA_DATOSGENERALES'

            IF (@NumeroAlertasServicio > 0)
            BEGIN
                IF (@NumeroAlertasServicio = 1)
                BEGIN
                    SELECT @DetalleAnalisis = CONCAT(@DetalleAnalisis, 'Existe nuevo servicio (', Descripcion, ') | ')
                    FROM #TablaTemporalValidacionDetalles
                    WHERE Tipo = 'ALERTA_SERVICIO'
                END
                ELSE
                BEGIN
                    SELECT @DetalleAnalisisServicios = STUFF(
                                                       (
                                                           SELECT ', ' + Descripcion
                                                           FROM #TablaTemporalValidacionDetalles
                                                           WHERE Tipo = 'ALERTA_SERVICIO'
                                                           FOR XML PATH('')
                                                       ),
                                                       1,
                                                       2,
                                                       ''
                                                            )

                    SELECT @DetalleAnalisis
                        = CONCAT(
                                    @DetalleAnalisis,
                                    'Existen ',
                                    CONVERT(VARCHAR(10), @NumeroAlertasServicio),
                                    ' nuevos servicios (',
                                    @DetalleAnalisisServicios,
                                    ') | '
                                );
                END
            END

            IF (@NumeroAlertasInstalacion > 0)
            BEGIN
                IF (@NumeroAlertasInstalacion = 1)
                BEGIN
                    SELECT @DetalleAnalisis
                        = CONCAT(@DetalleAnalisis, 'Existe nueva instalación (', Descripcion, ') | ')
                    FROM #TablaTemporalValidacionDetalles
                    WHERE Tipo = 'ALERTA_INSTALACION'
                END
                ELSE
                BEGIN
                    SELECT @DetalleAnalisisInstalaciones = STUFF(
                                                           (
                                                               SELECT ', ' + Descripcion
                                                               FROM #TablaTemporalValidacionDetalles
                                                               WHERE Tipo = 'ALERTA_INSTALACION'
                                                               FOR XML PATH('')
                                                           ),
                                                           1,
                                                           2,
                                                           ''
                                                                )

                    SELECT @DetalleAnalisis
                        = CONCAT(
                                    @DetalleAnalisis,
                                    'Existen ',
                                    CONVERT(VARCHAR(10), @NumeroAlertasInstalacion),
                                    ' nuevas instalaciones (',
                                    @DetalleAnalisisInstalaciones,
                                    ') | '
                                );
                END
            END


            IF (@NumeroAlertasDatosGenerales > 0)
            BEGIN
                /*===============================*/
                /*Bitácora Id Actividad Petrolera*/
                /*===============================*/
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existe un registro sin Id Actividad Petrolera en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'IdActividadPetrolera'
                      AND MultiplesDetalles = 0
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existen (',
                                CONVERT(VARCHAR(10), #TablaTemporalValidacionDetalles.NumeroDeDetalles),
                                ') registros sin Id Actividad Petrolera en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'IdActividadPetrolera'
                      AND MultiplesDetalles = 1
                /*============================*/
                /*Bitácora Actividad Petrolera*/
                /*============================*/
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existe un registro sin Actividad Petrolera en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'ActividadPetrolera'
                      AND MultiplesDetalles = 0
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existen (',
                                CONVERT(VARCHAR(10), #TablaTemporalValidacionDetalles.NumeroDeDetalles),
                                ') registros sin Actividad Petrolera en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'ActividadPetrolera'
                      AND MultiplesDetalles = 1
                /*===============================*/
                /*Bitácora Id Subactividad Petrolera*/
                /*===============================*/
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existe un registro sin Id Subactividad Petrolera en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'IdSubactividadPetrolera'
                      AND MultiplesDetalles = 0
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existen (',
                                CONVERT(VARCHAR(10), #TablaTemporalValidacionDetalles.NumeroDeDetalles),
                                ') registros sin Id Subactividad Petrolera en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'IdSubactividadPetrolera'
                      AND MultiplesDetalles = 1
                /*===============================*/
                /*Bitácora Subactividad Petrolera*/
                /*===============================*/
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existe un registro sin Subactividad Petrolera en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'SubactividadPetrolera'
                      AND MultiplesDetalles = 0
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existen (',
                                CONVERT(VARCHAR(10), #TablaTemporalValidacionDetalles.NumeroDeDetalles),
                                ') registros sin Subactividad Petrolera en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'SubactividadPetrolera'
                      AND MultiplesDetalles = 1
                /*=================*/
                /*Bitácora Id Tarea*/
                /*=================*/
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existe un registro sin Id Tarea en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'IdTarea'
                      AND MultiplesDetalles = 0
          SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existen (',
                                CONVERT(VARCHAR(10), #TablaTemporalValidacionDetalles.NumeroDeDetalles),
                                ') registros sin Id Tarea en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'IdTarea'
                      AND MultiplesDetalles = 1
                /*==============*/
                /*Bitácora Tarea*/
                /*==============*/
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existe un registro sin Tarea en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'Tarea'
                      AND MultiplesDetalles = 0
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existen (',
                                CONVERT(VARCHAR(10), #TablaTemporalValidacionDetalles.NumeroDeDetalles),
                                ') registros sin Tarea en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'Tarea'
                      AND MultiplesDetalles = 1

                /*==============*/
                /*Bitácora MONTO*/
                /*==============*/
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existe un registro sin Monto Presupuestado en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'MONTO'
                      AND MultiplesDetalles = 0
                SELECT @DetalleAnalisis
                    = CONCAT(
                                @DetalleAnalisis,
                                'Existen (',
                                CONVERT(VARCHAR(10), #TablaTemporalValidacionDetalles.NumeroDeDetalles),
                                ') registros sin Monto Presupuestado en ',
                                ISNULL(#TablaTemporalValidacionDetalles.Descripcion, ''),
                                ' | '
                            )
                FROM #TablaTemporalValidacionDetalles
                WHERE Tipo = 'ALERTA_DATOSGENERALES'
                      AND TipoDetalle = 'MONTO'
                      AND MultiplesDetalles = 1
            END

            SET @DetalleAnalisis = REPLACE(@DetalleAnalisis, '&amp;', '&');

            UPDATE CO_BitacoraPresupuesto
            SET DetalleAnalisis = LEFT(@DetalleAnalisis, LEN(@DetalleAnalisis) - 2)
            WHERE IdCarga = @Idcarga
        END
        ELSE
        BEGIN
            UPDATE CO_BitacoraPresupuesto
            SET DetalleAnalisis = 'Validación Exitosa'
            WHERE IdCarga = @Idcarga
        END

        COMMIT TRAN
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END
